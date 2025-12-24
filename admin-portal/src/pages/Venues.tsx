import { useEffect, useState } from "react";
import {
  venueApi,
  referenceApi,
  VenueResponse,
  VenueSeatingResponse,
  eventApi,
  CityResponse,
  SeatResponse,
  SeatRequest,
} from "@/lib/api";
import { usePermissions } from "@/hooks/usePermissions";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Plus, Edit, Trash2, Eye, Settings, X } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Select } from "@/components/ui/select";
import { showError, showSuccess } from "@/lib/errorHandler";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { EventResponse } from "@/lib/api";

export default function Venues() {
  const { canManageVenues } = usePermissions();
  const [venues, setVenues] = useState<VenueResponse[]>([]);
  const [cities, setCities] = useState<CityResponse[]>([]);
  const [venueEvents, setVenueEvents] = useState<EventResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [venueToDelete, setVenueToDelete] = useState<string | null>(null);
  const [selectedVenue, setSelectedVenue] = useState<VenueResponse | null>(
    null
  );
  const [editingVenue, setEditingVenue] = useState<VenueResponse | null>(null);
  const [selectedEventId, setSelectedEventId] = useState("");
  const [seating, setSeating] = useState<VenueSeatingResponse | null>(null);
  const [loadingSeating, setLoadingSeating] = useState(false);
  const [defaultSeats, setDefaultSeats] = useState<SeatResponse[]>([]);
  const [loadingDefaultSeats, setLoadingDefaultSeats] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    address: "",
    capacity: "",
    cityId: "",
  });
  // Seat management state
  const [seatManageDialogOpen, setSeatManageDialogOpen] = useState(false);
  const [venueForSeatManage, setVenueForSeatManage] = useState<VenueResponse | null>(null);
  const [seats, setSeats] = useState<SeatResponse[]>([]);
  const [loadingSeats, setLoadingSeats] = useState(false);
  const [seatEditDialogOpen, setSeatEditDialogOpen] = useState(false);
  const [editingSeat, setEditingSeat] = useState<SeatResponse | null>(null);
  const [seatFormData, setSeatFormData] = useState<SeatRequest>({
    sectionName: "",
    rowName: "",
    seatNumber: "",
  });
  const [bulkCreateDialogOpen, setBulkCreateDialogOpen] = useState(false);
  const [bulkSeatsData, setBulkSeatsData] = useState<string>("");

  useEffect(() => {
    loadVenues();
    loadCities();
  }, []);

  const loadVenues = async () => {
    try {
      const response = await venueApi.getVenues();
      setVenues(response.result);
    } catch (error) {
      console.error("Failed to load venues:", error);
    } finally {
      setLoading(false);
    }
  };

  const loadCities = async () => {
    try {
      const response = await referenceApi.getCities();
      setCities(response.result);
    } catch (error) {
      console.error("Failed to load cities:", error);
    }
  };

  const loadEventsForVenue = async (venueId: string) => {
    try {
      const response = await eventApi.getEvents({
        pageable: { page: 0, size: 100 },
      });
      // Filter events that use this venue
      const filteredEvents = response.result.content.filter(
        (event) => event.venueId === venueId
      );
      setVenueEvents(filteredEvents);
    } catch (error) {
      console.error("Failed to load events for venue:", error);
      showError(error);
    }
  };

  const handleCreate = () => {
    setEditingVenue(null);
    setFormData({ name: "", address: "", capacity: "", cityId: "" });
    setEditDialogOpen(true);
  };

  const handleEdit = (venue: VenueResponse) => {
    setEditingVenue(venue);
    setFormData({
      name: venue.name,
      address: venue.address || "",
      capacity: venue.capacity?.toString() || "",
      cityId: venue.city?.id || "",
    });
    setEditDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const venueData = {
        name: formData.name,
        cityId: formData.cityId,
        address: formData.address || undefined,
        capacity: formData.capacity ? parseInt(formData.capacity) : undefined,
      };

      if (editingVenue) {
        await venueApi.updateVenue(editingVenue.id, venueData);
      } else {
        await venueApi.createVenue(venueData);
      }
      setEditDialogOpen(false);
      showSuccess(
        editingVenue
          ? "Venue updated successfully"
          : "Venue created successfully"
      );
      loadVenues();
    } catch (error: any) {
      console.error("Failed to save venue:", error);
      showError(error);
    }
  };

  const handleDelete = (venueId: string) => {
    setVenueToDelete(venueId);
    setConfirmDialogOpen(true);
  };

  const confirmDelete = async () => {
    if (!venueToDelete) return;
    try {
      await venueApi.deleteVenue(venueToDelete);
      showSuccess("Venue deleted successfully");
      loadVenues();
      setVenueToDelete(null);
    } catch (error) {
      console.error("Failed to delete venue:", error);
      showError(error);
    }
  };

  const handleView = async (venue: VenueResponse) => {
    setSelectedVenue(venue);
    setSelectedEventId("");
    setSeating(null);
    setDefaultSeats([]);
    setVenueEvents([]);
    setViewDialogOpen(true);
    // Load events that use this venue
    await loadEventsForVenue(venue.id);
    // Load default seat map
    await loadDefaultSeats(venue.id);
  };

  const loadDefaultSeats = async (venueId: string) => {
    try {
      setLoadingDefaultSeats(true);
      const response = await venueApi.getSeatsByVenue(venueId);
      setDefaultSeats(response.result);
    } catch (error) {
      console.error("Failed to load default seats:", error);
      // Don't show error if seats don't exist yet
    } finally {
      setLoadingDefaultSeats(false);
    }
  };

  const handleManageSeats = async (venue: VenueResponse) => {
    setVenueForSeatManage(venue);
    setSeatManageDialogOpen(true);
    await loadSeats(venue.id);
  };

  const loadSeats = async (venueId: string) => {
    try {
      setLoadingSeats(true);
      const response = await venueApi.getSeatsByVenue(venueId);
      setSeats(response.result);
    } catch (error) {
      console.error("Failed to load seats:", error);
      showError(error);
    } finally {
      setLoadingSeats(false);
    }
  };

  const handleCreateSeat = () => {
    setEditingSeat(null);
    setSeatFormData({
      sectionName: "",
      rowName: "",
      seatNumber: "",
    });
    setSeatEditDialogOpen(true);
  };

  const handleEditSeat = (seat: SeatResponse) => {
    setEditingSeat(seat);
    setSeatFormData({
      sectionName: seat.sectionName,
      rowName: seat.rowName,
      seatNumber: seat.seatNumber,
    });
    setSeatEditDialogOpen(true);
  };

  const handleSeatSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!venueForSeatManage) return;

    try {
      let response;
      if (editingSeat) {
        response = await venueApi.updateSeat(venueForSeatManage.id, editingSeat.id, seatFormData);
        showSuccess("Seat updated successfully");
      } else {
        response = await venueApi.createSeat(venueForSeatManage.id, seatFormData);
        showSuccess("Seat created successfully");
      }
      setSeatEditDialogOpen(false);
      
      // Reload seats to get updated list with section/row
      await loadSeats(venueForSeatManage.id);
    } catch (error) {
      console.error("Failed to save seat:", error);
      showError(error);
    }
  };

  const handleDeleteSeat = async (venueId: string, seatId: string) => {
    try {
      await venueApi.deleteSeat(venueId, seatId);
      showSuccess("Seat deleted successfully");
      await loadSeats(venueId);
    } catch (error) {
      console.error("Failed to delete seat:", error);
      showError(error);
    }
  };

  const handleBulkCreate = async () => {
    if (!venueForSeatManage) return;

    try {
      // Parse bulk seats data (format: section,row,seatNumber per line)
      const lines = bulkSeatsData.split("\n").filter((line) => line.trim());
      const seatsToCreate: SeatRequest[] = lines.map((line) => {
        const parts = line.split(",").map((p) => p.trim());
        if (parts.length !== 3) {
          throw new Error(`Invalid format: ${line}. Expected: section,row,seatNumber`);
        }
        return {
          sectionName: parts[0],
          rowName: parts[1],
          seatNumber: parts[2],
        };
      });

      const response = await venueApi.createBulkSeats(venueForSeatManage.id, seatsToCreate);
      showSuccess(`Created ${seatsToCreate.length} seats successfully`);
      setBulkCreateDialogOpen(false);
      setBulkSeatsData("");
      
      // Use the response data which should include section/row, or reload
      if (response.result && response.result.length > 0) {
        // Check if response includes section/row
        const hasSectionRow = response.result.some(seat => seat.sectionName || seat.rowName);
        if (hasSectionRow) {
          // Merge with existing seats
          setSeats(prev => [...prev, ...response.result]);
        } else {
          // Reload to get full details
          await loadSeats(venueForSeatManage.id);
        }
      } else {
        await loadSeats(venueForSeatManage.id);
      }
    } catch (error) {
      console.error("Failed to create bulk seats:", error);
      showError(error);
    }
  };

  const loadSeating = async () => {
    if (!selectedVenue || !selectedEventId) return;
    try {
      setLoadingSeating(true);
      const response = await venueApi.getVenueSeating(
        selectedVenue.id,
        selectedEventId
      );
      setSeating(response.result);
    } catch (error) {
      console.error("Failed to load seating:", error);
      showError(error);
    } finally {
      setLoadingSeating(false);
    }
  };

  // Organize default seats by status for display
  const organizeSeatsByStatus = (seats: SeatResponse[]) => {
    const organized: Record<string, SeatResponse[]> = {
      AVAILABLE: [],
      RESERVED: [],
      SOLD: [],
      BLOCKED: [],
    };
    seats.forEach((seat) => {
      if (organized[seat.status]) {
        organized[seat.status].push(seat);
      }
    });
    return organized;
  };

  const getSeatStatusColor = (status: string) => {
    switch (status) {
      case "AVAILABLE":
        return "bg-green-100 text-green-800 border-green-300";
      case "RESERVED":
        return "bg-yellow-100 text-yellow-800 border-yellow-300";
      case "SOLD":
        return "bg-red-100 text-red-800 border-red-300";
      case "BLOCKED":
        return "bg-gray-100 text-gray-800 border-gray-300";
      default:
        return "bg-gray-100 text-gray-800 border-gray-300";
    }
  };

  // Natural sort function for alphanumeric strings (handles ABC 123 properly)
  const naturalSort = (a: string, b: string): number => {
    // Split strings into parts (text and numbers)
    const aParts = a.match(/(\d+|\D+)/g) || [];
    const bParts = b.match(/(\d+|\D+)/g) || [];

    const minLength = Math.min(aParts.length, bParts.length);

    for (let i = 0; i < minLength; i++) {
      const aPart = aParts[i];
      const bPart = bParts[i];

      // If both are numbers, compare numerically
      if (/^\d+$/.test(aPart) && /^\d+$/.test(bPart)) {
        const numA = parseInt(aPart, 10);
        const numB = parseInt(bPart, 10);
        if (numA !== numB) {
          return numA - numB;
        }
      } else {
        // Compare as strings (case-insensitive)
        const strA = aPart.toLowerCase();
        const strB = bPart.toLowerCase();
        if (strA !== strB) {
          return strA < strB ? -1 : 1;
        }
      }
    }

    // If all parts are equal, shorter string comes first
    return aParts.length - bParts.length;
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Venues</h1>
          <p className="text-muted-foreground">
            Manage venues and seating charts
          </p>
        </div>
        {canManageVenues() && (
          <Button onClick={handleCreate}>
            <Plus className="mr-2 h-4 w-4" />
            Add Venue
          </Button>
        )}
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Address</TableHead>
                <TableHead>City</TableHead>
                <TableHead>Capacity</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {venues.map((venue) => (
                <TableRow key={venue.id}>
                  <TableCell className="font-medium">{venue.name}</TableCell>
                  <TableCell>{venue.address || "-"}</TableCell>
                  <TableCell>{venue.city?.name || "-"}</TableCell>
                  <TableCell>{venue.capacity || "-"}</TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleView(venue)}
                        title="View venue details"
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                      {canManageVenues() && (
                        <>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleManageSeats(venue)}
                            title="Manage seats"
                          >
                            <Settings className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEdit(venue)}
                            title="Edit venue"
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(venue.id)}
                            title="Delete venue"
                          >
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        </>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Create/Edit Dialog */}
      <Dialog open={editDialogOpen} onOpenChange={setEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {editingVenue ? "Edit Venue" : "Create Venue"}
            </DialogTitle>
            <DialogDescription>
              {editingVenue
                ? "Update venue information"
                : "Add a new venue to the system"}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit}>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="name">Venue Name *</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) =>
                    setFormData({ ...formData, name: e.target.value })
                  }
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="cityId">City *</Label>
                <Select
                  id="cityId"
                  value={formData.cityId}
                  onChange={(e) =>
                    setFormData({ ...formData, cityId: e.target.value })
                  }
                  required
                >
                  <option value="">Select a city</option>
                  {cities.map((city) => (
                    <option key={city.id} value={city.id}>
                      {city.name}
                    </option>
                  ))}
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="address">Address</Label>
                <Input
                  id="address"
                  value={formData.address}
                  onChange={(e) =>
                    setFormData({ ...formData, address: e.target.value })
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="capacity">Capacity</Label>
                <Input
                  id="capacity"
                  type="number"
                  value={formData.capacity}
                  onChange={(e) =>
                    setFormData({ ...formData, capacity: e.target.value })
                  }
                  min="0"
                />
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setEditDialogOpen(false)}
              >
                Cancel
              </Button>
              <Button type="submit">Save</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* View Dialog */}
      <Dialog open={viewDialogOpen} onOpenChange={setViewDialogOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{selectedVenue?.name}</DialogTitle>
            <DialogDescription>
              {selectedVenue?.address} - {selectedVenue?.city?.name}
            </DialogDescription>
          </DialogHeader>
          {selectedVenue && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-muted-foreground">Address</Label>
                  <p>{selectedVenue.address || "-"}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">City</Label>
                  <p>{selectedVenue.city?.name || "-"}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Capacity</Label>
                  <p>{selectedVenue.capacity || "-"}</p>
                </div>
              </div>

              <div className="border-t pt-4">
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <Label className="text-lg font-semibold">Seat Map</Label>
                    <div className="flex gap-2">
                      <Select
                        value={selectedEventId}
                        onChange={(e) => {
                          const eventId = e.target.value;
                          setSelectedEventId(eventId);
                          if (eventId) {
                            loadSeating();
                          } else {
                            setSeating(null);
                          }
                        }}
                        className="w-64"
                      >
                        <option value="">Default Seat Map</option>
                        {venueEvents.length > 0 ? (
                          venueEvents.map((event) => (
                            <option key={event.id} value={event.id}>
                              {event.name}
                            </option>
                          ))
                        ) : (
                          <option value="" disabled>
                            No events found for this venue
                          </option>
                        )}
                      </Select>
                    </div>
                  </div>

                  {/* Show event-specific seating chart if event is selected */}
                  {selectedEventId && seating ? (
                    <div className="space-y-4">
                      <div>
                        <Label className="text-lg font-semibold">
                          Seating Chart
                        </Label>
                        <p className="text-sm text-muted-foreground">
                          {seating.venueName} - Event:{" "}
                          {venueEvents.find((e) => e.id === seating.eventId)
                            ?.name || "Unknown Event"}
                        </p>
                      </div>
                      {seating.sections && seating.sections.length > 0 ? (
                        <div className="space-y-6">
                          {seating.sections.map(
                            (section: any, sectionIndex: number) => (
                              <div
                                key={sectionIndex}
                                className="border rounded-lg p-4"
                              >
                                <h3 className="font-semibold mb-3">
                                  {section.sectionName}
                                </h3>
                                {section.rows && section.rows.length > 0 ? (
                                  <div className="space-y-3">
                                    {[...section.rows]
                                      .sort((a: any, b: any) =>
                                        naturalSort(
                                          a.rowName || "",
                                          b.rowName || ""
                                        )
                                      )
                                      .map((row: any, rowIndex: number) => (
                                        <div
                                          key={rowIndex}
                                          className="space-y-1"
                                        >
                                          <div className="text-sm font-medium text-muted-foreground">
                                            Row {row.rowName}
                                          </div>
                                          <div className="flex flex-wrap gap-1">
                                            {row.seats &&
                                              [...row.seats]
                                                .sort((a: any, b: any) =>
                                                  naturalSort(
                                                    a.seatNumber || "",
                                                    b.seatNumber || ""
                                                  )
                                                )
                                                .map((seat: any) => (
                                                  <div
                                                    key={seat.id}
                                                    className={`
                                              px-2 py-1 text-xs border rounded
                                              ${getSeatStatusColor(seat.status)}
                                            `}
                                                    title={`${seat.seatNumber} - ${seat.status}`}
                                                  >
                                                    {seat.seatNumber}
                                                  </div>
                                                ))}
                                          </div>
                                        </div>
                                      ))}
                                  </div>
                                ) : (
                                  <p className="text-sm text-muted-foreground">
                                    No rows defined
                                  </p>
                                )}
                              </div>
                            )
                          )}
                        </div>
                      ) : (
                        <p className="text-sm text-muted-foreground">
                          No seating chart available
                        </p>
                      )}

                      <div className="flex gap-2 flex-wrap">
                        <div className="flex items-center gap-2">
                          <div className="w-4 h-4 bg-green-100 border border-green-300 rounded"></div>
                          <span className="text-xs">Available</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <div className="w-4 h-4 bg-yellow-100 border border-yellow-300 rounded"></div>
                          <span className="text-xs">Reserved</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <div className="w-4 h-4 bg-red-100 border border-red-300 rounded"></div>
                          <span className="text-xs">Sold</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <div className="w-4 h-4 bg-gray-100 border border-gray-300 rounded"></div>
                          <span className="text-xs">Blocked</span>
                        </div>
                      </div>
                    </div>
                  ) : null}

                  {/* Show default seat map if no event selected */}
                  {!selectedEventId && (
                    <div className="space-y-4">
                      {loadingDefaultSeats ? (
                        <div className="text-center py-8">Loading seat map...</div>
                      ) : defaultSeats.length === 0 ? (
                        <div className="text-center py-8 text-muted-foreground">
                          No seats configured for this venue yet. Use "Manage Seats" to add seats.
                        </div>
                      ) : (
                        <>
                          <div>
                            <Label className="text-base font-medium">
                              Default Seat Map ({defaultSeats.length} seats)
                            </Label>
                            <p className="text-sm text-muted-foreground">
                              Showing all seats. Select an event above to see event-specific availability.
                            </p>
                          </div>
                          <div className="space-y-6">
                            {(() => {
                              // Organize seats by section and row
                              const organizedSeats: Record<
                                string,
                                Record<string, SeatResponse[]>
                              > = {};
                              defaultSeats.forEach((seat) => {
                                if (!organizedSeats[seat.sectionName]) {
                                  organizedSeats[seat.sectionName] = {};
                                }
                                if (!organizedSeats[seat.sectionName][seat.rowName]) {
                                  organizedSeats[seat.sectionName][seat.rowName] = [];
                                }
                                organizedSeats[seat.sectionName][seat.rowName].push(seat);
                              });

                              // Sort sections and rows
                              const sortedSections = Object.keys(organizedSeats).sort(
                                (a, b) => naturalSort(a, b)
                              );

                              return sortedSections.map((sectionName) => {
                                const rows = organizedSeats[sectionName];
                                const sortedRows = Object.keys(rows).sort((a, b) =>
                                  naturalSort(a, b)
                                );

                                return (
                                  <div
                                    key={sectionName}
                                    className="border rounded-lg p-4"
                                  >
                                    <h3 className="font-semibold mb-3">
                                      {sectionName}
                                    </h3>
                                    {sortedRows.length > 0 ? (
                                      <div className="space-y-3">
                                        {sortedRows.map((rowName) => {
                                          const rowSeats = rows[rowName].sort((a, b) =>
                                            naturalSort(a.seatNumber, b.seatNumber)
                                          );

                                          return (
                                            <div
                                              key={rowName}
                                              className="space-y-1"
                                            >
                                              <div className="text-sm font-medium text-muted-foreground">
                                                Row {rowName}
                                              </div>
                                              <div className="flex flex-wrap gap-1">
                                                {rowSeats.map((seat) => (
                                                  <div
                                                    key={seat.id}
                                                    className={`
                                                      px-2 py-1 text-xs border rounded cursor-default
                                                      ${getSeatStatusColor(seat.status)}
                                                      hover:opacity-80 transition-opacity
                                                    `}
                                                    title={`Seat ${seat.seatNumber} - ${seat.status}`}
                                                  >
                                                    {seat.seatNumber}
                                                  </div>
                                                ))}
                                              </div>
                                            </div>
                                          );
                                        })}
                                      </div>
                                    ) : (
                                      <p className="text-sm text-muted-foreground">
                                        No rows defined
                                      </p>
                                    )}
                                  </div>
                                );
                              });
                            })()}
                          </div>

                          {/* Legend */}
                          <div className="flex gap-2 flex-wrap pt-2 border-t">
                            <div className="flex items-center gap-2">
                              <div className="w-4 h-4 bg-green-100 border border-green-300 rounded"></div>
                              <span className="text-xs">Available</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <div className="w-4 h-4 bg-yellow-100 border border-yellow-300 rounded"></div>
                              <span className="text-xs">Reserved</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <div className="w-4 h-4 bg-red-100 border border-red-300 rounded"></div>
                              <span className="text-xs">Sold</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <div className="w-4 h-4 bg-gray-100 border border-gray-300 rounded"></div>
                              <span className="text-xs">Blocked</span>
                            </div>
                          </div>
                        </>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={confirmDialogOpen}
        onOpenChange={setConfirmDialogOpen}
        title="Delete Venue"
        description="Are you sure you want to delete this venue? This action cannot be undone."
        confirmText="Delete"
        cancelText="Cancel"
        onConfirm={confirmDelete}
        variant="destructive"
      />

      {/* Seat Management Dialog */}
      <Dialog open={seatManageDialogOpen} onOpenChange={setSeatManageDialogOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              Manage Seats - {venueForSeatManage?.name}
            </DialogTitle>
            <DialogDescription>
              Create, edit, and delete seats for this venue
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <div className="text-sm text-muted-foreground">
                {seats.length} seat{seats.length !== 1 ? "s" : ""} total
              </div>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  onClick={() => setBulkCreateDialogOpen(true)}
                >
                  Bulk Create
                </Button>
                <Button onClick={handleCreateSeat}>
                  <Plus className="mr-2 h-4 w-4" />
                  Add Seat
                </Button>
              </div>
            </div>

            {loadingSeats ? (
              <div className="text-center py-8">Loading seats...</div>
            ) : seats.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">
                No seats found. Create your first seat to get started.
              </div>
            ) : (
              <div className="space-y-6">
                {(() => {
                  // Organize seats by section and row
                  const organizedSeats: Record<
                    string,
                    Record<string, SeatResponse[]>
                  > = {};
                  seats.forEach((seat) => {
                    if (!organizedSeats[seat.sectionName]) {
                      organizedSeats[seat.sectionName] = {};
                    }
                    if (!organizedSeats[seat.sectionName][seat.rowName]) {
                      organizedSeats[seat.sectionName][seat.rowName] = [];
                    }
                    organizedSeats[seat.sectionName][seat.rowName].push(seat);
                  });

                  // Sort sections and rows
                  const sortedSections = Object.keys(organizedSeats).sort(
                    (a, b) => naturalSort(a, b)
                  );

                  return sortedSections.map((sectionName) => {
                    const rows = organizedSeats[sectionName];
                    const sortedRows = Object.keys(rows).sort((a, b) =>
                      naturalSort(a, b)
                    );

                    return (
                      <div
                        key={sectionName}
                        className="border rounded-lg p-4 space-y-4"
                      >
                        <h3 className="font-semibold text-lg">{sectionName}</h3>
                        {sortedRows.map((rowName) => {
                          const rowSeats = rows[rowName].sort((a, b) =>
                            naturalSort(a.seatNumber, b.seatNumber)
                          );

                          return (
                            <div key={rowName} className="space-y-2">
                              <div className="text-sm font-medium text-muted-foreground">
                                Row {rowName}
                              </div>
                              <div className="flex flex-wrap gap-2">
                                {rowSeats.map((seat) => (
                                  <div
                                    key={seat.id}
                                    className="group relative"
                                  >
                                    <div
                                      className={`
                                        px-3 py-2 text-sm border rounded cursor-pointer
                                        ${getSeatStatusColor(seat.status)}
                                        hover:opacity-80 transition-opacity
                                      `}
                                      title={`${seat.sectionName} - Row ${seat.rowName} - Seat ${seat.seatNumber} - ${seat.status}`}
                                    >
                                      {seat.seatNumber}
                                    </div>
                                    <div className="absolute top-full left-0 mt-1 opacity-0 group-hover:opacity-100 transition-opacity z-10 bg-card border rounded shadow-lg p-2 flex gap-2">
                                      <Button
                                        variant="ghost"
                                        size="icon"
                                        className="h-8 w-8"
                                        onClick={() => handleEditSeat(seat)}
                                        title="Edit seat"
                                      >
                                        <Edit className="h-4 w-4" />
                                      </Button>
                                      <Button
                                        variant="ghost"
                                        size="icon"
                                        className="h-8 w-8 text-destructive"
                                        onClick={() =>
                                          venueForSeatManage &&
                                          handleDeleteSeat(
                                            venueForSeatManage.id,
                                            seat.id
                                          )
                                        }
                                        title="Delete seat"
                                      >
                                        <Trash2 className="h-4 w-4" />
                                      </Button>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    );
                  });
                })()}
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>

      {/* Create/Edit Seat Dialog */}
      <Dialog open={seatEditDialogOpen} onOpenChange={setSeatEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {editingSeat ? "Edit Seat" : "Create Seat"}
            </DialogTitle>
            <DialogDescription>
              {editingSeat
                ? "Update seat information"
                : "Add a new seat to this venue"}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSeatSubmit}>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="sectionName">Section Name *</Label>
                <Input
                  id="sectionName"
                  value={seatFormData.sectionName}
                  onChange={(e) =>
                    setSeatFormData({
                      ...seatFormData,
                      sectionName: e.target.value,
                    })
                  }
                  required
                  placeholder="e.g., Main Floor, Balcony"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="rowName">Row Name *</Label>
                <Input
                  id="rowName"
                  value={seatFormData.rowName}
                  onChange={(e) =>
                    setSeatFormData({
                      ...seatFormData,
                      rowName: e.target.value,
                    })
                  }
                  required
                  placeholder="e.g., A, B, 1, 2"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="seatNumber">Seat Number *</Label>
                <Input
                  id="seatNumber"
                  value={seatFormData.seatNumber}
                  onChange={(e) =>
                    setSeatFormData({
                      ...seatFormData,
                      seatNumber: e.target.value,
                    })
                  }
                  required
                  placeholder="e.g., 1, 2, 3"
                />
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setSeatEditDialogOpen(false)}
              >
                Cancel
              </Button>
              <Button type="submit">Save</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Bulk Create Seats Dialog */}
      <Dialog
        open={bulkCreateDialogOpen}
        onOpenChange={setBulkCreateDialogOpen}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Bulk Create Seats</DialogTitle>
            <DialogDescription>
              Enter seats in the format: section,row,seatNumber (one per line)
              <br />
              Example:
              <br />
              Main Floor,A,1
              <br />
              Main Floor,A,2
              <br />
              Balcony,B,1
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="bulkSeats">Seats Data</Label>
              <Textarea
                id="bulkSeats"
                value={bulkSeatsData}
                onChange={(e) => setBulkSeatsData(e.target.value)}
                rows={10}
                placeholder="Main Floor,A,1&#10;Main Floor,A,2&#10;Balcony,B,1"
                className="font-mono text-sm"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                setBulkCreateDialogOpen(false);
                setBulkSeatsData("");
              }}
            >
              Cancel
            </Button>
            <Button onClick={handleBulkCreate}>Create Seats</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
