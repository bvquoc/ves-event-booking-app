import { useEffect, useState } from "react";
import {
  venueApi,
  referenceApi,
  VenueResponse,
  VenueSeatingResponse,
  eventApi,
  CityResponse,
} from "@/lib/api";
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
import { Plus, Edit, Trash2, Eye } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Select } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { EventResponse } from "@/lib/api";

export default function Venues() {
  const [venues, setVenues] = useState<VenueResponse[]>([]);
  const [cities, setCities] = useState<CityResponse[]>([]);
  const [events, setEvents] = useState<EventResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [selectedVenue, setSelectedVenue] = useState<VenueResponse | null>(
    null
  );
  const [editingVenue, setEditingVenue] = useState<VenueResponse | null>(null);
  const [selectedEventId, setSelectedEventId] = useState("");
  const [seating, setSeating] = useState<VenueSeatingResponse | null>(null);
  const [loadingSeating, setLoadingSeating] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    address: "",
    capacity: "",
    cityId: "",
  });

  useEffect(() => {
    loadVenues();
    loadCities();
    loadEvents();
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

  const loadEvents = async () => {
    try {
      const response = await eventApi.getEvents({
        pageable: { page: 0, size: 100 },
      });
      setEvents(response.result.content);
    } catch (error) {
      console.error("Failed to load events:", error);
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
      loadVenues();
    } catch (error: any) {
      console.error("Failed to save venue:", error);
      alert(error.response?.data?.message || "Failed to save venue");
    }
  };

  const handleDelete = async (venueId: string) => {
    if (!confirm("Are you sure you want to delete this venue?")) return;
    try {
      await venueApi.deleteVenue(venueId);
      loadVenues();
    } catch (error) {
      console.error("Failed to delete venue:", error);
      alert("Failed to delete venue");
    }
  };

  const handleView = async (venue: VenueResponse) => {
    setSelectedVenue(venue);
    setSelectedEventId("");
    setSeating(null);
    setViewDialogOpen(true);
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
      alert("Failed to load seating chart");
    } finally {
      setLoadingSeating(false);
    }
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
        <Button onClick={handleCreate}>
          <Plus className="mr-2 h-4 w-4" />
          Add Venue
        </Button>
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
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleEdit(venue)}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleDelete(venue.id)}
                      >
                        <Trash2 className="h-4 w-4 text-destructive" />
                      </Button>
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
                  <div>
                    <Label>View Seating Chart for Event</Label>
                    <div className="flex gap-2 mt-2">
                      <Select
                        value={selectedEventId}
                        onChange={(e) => {
                          setSelectedEventId(e.target.value);
                          setSeating(null);
                        }}
                        className="flex-1"
                      >
                        <option value="">Select an event</option>
                        {events.map((event) => (
                          <option key={event.id} value={event.id}>
                            {event.name}
                          </option>
                        ))}
                      </Select>
                      <Button
                        onClick={loadSeating}
                        disabled={!selectedEventId || loadingSeating}
                      >
                        {loadingSeating ? "Loading..." : "Load Seating"}
                      </Button>
                    </div>
                  </div>

                  {seating && (
                    <div className="space-y-4">
                      <div>
                        <Label className="text-lg font-semibold">
                          Seating Chart
                        </Label>
                        <p className="text-sm text-muted-foreground">
                          {seating.venueName} - Event:{" "}
                          {events.find((e) => e.id === seating.eventId)?.name}
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
                                    {section.rows.map(
                                      (row: any, rowIndex: number) => (
                                        <div
                                          key={rowIndex}
                                          className="space-y-1"
                                        >
                                          <div className="text-sm font-medium text-muted-foreground">
                                            Row {row.rowName}
                                          </div>
                                          <div className="flex flex-wrap gap-1">
                                            {row.seats &&
                                              row.seats.map((seat: any) => (
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
                                      )
                                    )}
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
                  )}
                </div>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
