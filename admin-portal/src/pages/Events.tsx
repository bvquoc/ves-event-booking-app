import { useEffect, useState } from "react";
import {
  eventApi,
  referenceApi,
  EventResponse,
  EventDetailResponse,
  EventRequest,
  CategoryResponse,
  CityResponse,
  VenueResponse,
  TicketTypeRequest,
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
import { Plus, Edit, Trash2, Eye, Search, X } from "lucide-react";
import { format } from "date-fns";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { venueApi, VenueSeatingResponse } from "@/lib/api";
import { usePermissions } from "@/hooks/usePermissions";
import { useAuth } from "@/contexts/AuthContext";

export default function Events() {
  const { canManageEvents, isAdmin } = usePermissions();
  const { user } = useAuth();
  const [events, setEvents] = useState<EventResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);

  // Filters
  const [searchQuery, setSearchQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("");
  const [cityFilter, setCityFilter] = useState("");
  const [trendingFilter, setTrendingFilter] = useState<boolean | undefined>(
    undefined
  );

  // Reference data
  const [categories, setCategories] = useState<CategoryResponse[]>([]);
  const [cities, setCities] = useState<CityResponse[]>([]);
  const [venues, setVenues] = useState<VenueResponse[]>([]);

  // Dialog state
  const [dialogOpen, setDialogOpen] = useState(false);
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [editingEvent, setEditingEvent] = useState<EventDetailResponse | null>(
    null
  );
  const [viewingEvent, setViewingEvent] = useState<EventDetailResponse | null>(
    null
  );
  const [seating, setSeating] = useState<VenueSeatingResponse | null>(null);
  const [loadingSeating, setLoadingSeating] = useState(false);
  const [formData, setFormData] = useState<Partial<EventRequest>>({
    name: "",
    slug: "",
    description: "",
    longDescription: "",
    categoryId: "",
    cityId: "",
    venueId: "",
    venueName: "",
    venueAddress: "",
    thumbnail: "",
    images: [],
    startDate: "",
    endDate: "",
    currency: "VND",
    isTrending: false,
    organizerName: "",
    organizerLogo: "",
    terms: "",
    cancellationPolicy: "",
    tags: [],
    ticketTypes: [],
  });
  const [ticketTypes, setTicketTypes] = useState<TicketTypeRequest[]>([]);
  const [newTicketType, setNewTicketType] = useState<
    Partial<TicketTypeRequest>
  >({
    name: "",
    description: "",
    price: 0,
    currency: "VND",
    available: 0,
    maxPerOrder: 1,
    benefits: [],
    requiresSeatSelection: false,
  });

  useEffect(() => {
    loadEvents();
    loadReferenceData();
  }, [page, categoryFilter, cityFilter, trendingFilter]);

  const loadReferenceData = async () => {
    try {
      const [categoriesRes, citiesRes, venuesRes] = await Promise.all([
        referenceApi.getCategories(),
        referenceApi.getCities(),
        venueApi.getVenues(),
      ]);
      setCategories(categoriesRes.result);
      setCities(citiesRes.result);
      setVenues(venuesRes.result);
    } catch (error) {
      console.error("Failed to load reference data:", error);
    }
  };

  const loadEvents = async () => {
    try {
      setLoading(true);
      const params: any = {
        pageable: { page, size: 10 },
      };
      if (searchQuery) params.search = searchQuery;
      if (categoryFilter) params.category = categoryFilter;
      if (cityFilter) params.city = cityFilter;
      if (trendingFilter !== undefined) params.trending = trendingFilter;

      const response = await eventApi.getEvents(params);
      let filteredEvents = response.result.content;
      let filteredTotal = response.result.totalElements;

      // For non-admin users, filter to show only their events
      // Filter by organizerName matching user's name or username
      if (!isAdmin() && user) {
        filteredEvents = response.result.content.filter((event) => {
          const userFullName = `${user.firstName} ${user.lastName}`.trim();
          return (
            event.organizerName === user.username ||
            event.organizerName === userFullName ||
            event.organizerName === user.firstName ||
            event.organizerName === user.lastName
          );
        });
        filteredTotal = filteredEvents.length;
      }

      setEvents(filteredEvents);
      setTotalPages(response.result.totalPages);
      setTotalElements(filteredTotal);
    } catch (error) {
      console.error("Failed to load events:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = () => {
    setPage(0);
    loadEvents();
  };

  const handleCreate = () => {
    setEditingEvent(null);
    setFormData({
      name: "",
      slug: "",
      description: "",
      longDescription: "",
      categoryId: "",
      cityId: "",
      venueId: "",
      venueName: "",
      venueAddress: "",
      thumbnail: "",
      images: [],
      startDate: "",
      endDate: "",
      currency: "VND",
      isTrending: false,
      organizerName: "",
      organizerLogo: "",
      terms: "",
      cancellationPolicy: "",
      tags: [],
      ticketTypes: [],
    });
    setTicketTypes([]);
    setDialogOpen(true);
  };

  const handleEdit = async (eventId: string) => {
    try {
      const response = await eventApi.getEventDetails(eventId);
      const event = response.result;
      setEditingEvent(event);
      setFormData({
        name: event.name,
        slug: event.slug,
        description: event.description,
        longDescription: event.longDescription,
        categoryId: event.category?.id || "",
        cityId: event.city?.id || "",
        venueId: event.venueId || "",
        venueName: event.venueName || "",
        venueAddress: event.venueAddress || "",
        thumbnail: event.thumbnail || "",
        images: event.images || [],
        startDate: event.startDate
          ? new Date(event.startDate).toISOString().slice(0, 16)
          : "",
        endDate: event.endDate
          ? new Date(event.endDate).toISOString().slice(0, 16)
          : "",
        currency: event.currency || "VND",
        isTrending: event.isTrending || false,
        organizerName: event.organizerName || "",
        organizerLogo: event.organizerLogo || "",
        terms: event.terms || "",
        cancellationPolicy: event.cancellationPolicy || "",
        tags: event.tags || [],
        ticketTypes: [],
      });
      setTicketTypes(
        event.ticketTypes?.map((tt) => ({
          name: tt.name,
          description: tt.description,
          price: tt.price,
          currency: tt.currency || "VND",
          available: tt.available,
          maxPerOrder: tt.maxPerOrder,
          benefits: tt.benefits || [],
          requiresSeatSelection: tt.requiresSeatSelection,
        })) || []
      );
      setDialogOpen(true);
    } catch (error) {
      console.error("Failed to load event details:", error);
      alert("Failed to load event details");
    }
  };

  const handleView = async (eventId: string) => {
    try {
      const response = await eventApi.getEventDetails(eventId);
      const event = response.result;
      setViewingEvent(event);
      setSeating(null);
      setViewDialogOpen(true);

      // Load seating chart if venue is available
      if (event.venueId) {
        loadSeatingChart(event.venueId, eventId);
      }
    } catch (error) {
      console.error("Failed to load event details:", error);
      alert("Failed to load event details");
    }
  };

  const loadSeatingChart = async (venueId: string, eventId: string) => {
    try {
      setLoadingSeating(true);
      const response = await venueApi.getVenueSeating(venueId, eventId);
      setSeating(response.result);
    } catch (error) {
      console.error("Failed to load seating chart:", error);
      // Don't show alert, just silently fail - not all events have seating
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const eventData: EventRequest = {
        name: formData.name!,
        slug: formData.slug!,
        description: formData.description,
        longDescription: formData.longDescription,
        categoryId: formData.categoryId!,
        cityId: formData.cityId!,
        venueId: formData.venueId,
        venueName: formData.venueName,
        venueAddress: formData.venueAddress,
        thumbnail: formData.thumbnail,
        images: formData.images || [],
        startDate: new Date(formData.startDate!).toISOString(),
        endDate: formData.endDate
          ? new Date(formData.endDate).toISOString()
          : undefined,
        currency: formData.currency,
        isTrending: formData.isTrending || false,
        organizerName: formData.organizerName,
        organizerLogo: formData.organizerLogo,
        terms: formData.terms,
        cancellationPolicy: formData.cancellationPolicy,
        tags: formData.tags || [],
        ticketTypes: ticketTypes,
      };

      if (editingEvent) {
        await eventApi.updateEvent(editingEvent.id, eventData);
      } else {
        await eventApi.createEvent(eventData);
      }
      setDialogOpen(false);
      loadEvents();
    } catch (error: any) {
      console.error("Failed to save event:", error);
      alert(error.response?.data?.message || "Failed to save event");
    }
  };

  const handleDelete = async (eventId: string) => {
    if (!confirm("Are you sure you want to delete this event?")) return;
    try {
      await eventApi.deleteEvent(eventId);
      loadEvents();
    } catch (error) {
      console.error("Failed to delete event:", error);
      alert("Failed to delete event");
    }
  };

  const addTicketType = () => {
    if (newTicketType.name && newTicketType.price && newTicketType.available) {
      setTicketTypes([
        ...ticketTypes,
        {
          name: newTicketType.name!,
          description: newTicketType.description,
          price: newTicketType.price!,
          currency: newTicketType.currency || "VND",
          available: newTicketType.available!,
          maxPerOrder: newTicketType.maxPerOrder || 1,
          benefits: newTicketType.benefits || [],
          requiresSeatSelection: newTicketType.requiresSeatSelection || false,
        },
      ]);
      setNewTicketType({
        name: "",
        description: "",
        price: 0,
        currency: "VND",
        available: 0,
        maxPerOrder: 1,
        benefits: [],
        requiresSeatSelection: false,
      });
    }
  };

  const removeTicketType = (index: number) => {
    setTicketTypes(ticketTypes.filter((_, i) => i !== index));
  };

  if (loading && events.length === 0) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">
            {isAdmin() ? "Events" : "My Events"}
          </h1>
          <p className="text-muted-foreground">
            {isAdmin() ? "Manage events" : "View your events"} ({totalElements}{" "}
            total)
          </p>
        </div>
        {canManageEvents() && (
          <Button onClick={handleCreate}>
            <Plus className="mr-2 h-4 w-4" />
            Add Event
          </Button>
        )}
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="relative">
              <Input
                placeholder="Search events..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyPress={(e) => e.key === "Enter" && handleSearch()}
              />
              <Button
                variant="ghost"
                size="icon"
                className="absolute right-0 top-0"
                onClick={handleSearch}
              >
                <Search className="h-4 w-4" />
              </Button>
            </div>
            <Select
              value={categoryFilter}
              onChange={(e) => {
                setCategoryFilter(e.target.value);
                setPage(0);
              }}
            >
              <option value="">All Categories</option>
              {categories.map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                </option>
              ))}
            </Select>
            <Select
              value={cityFilter}
              onChange={(e) => {
                setCityFilter(e.target.value);
                setPage(0);
              }}
            >
              <option value="">All Cities</option>
              {cities.map((city) => (
                <option key={city.id} value={city.id}>
                  {city.name}
                </option>
              ))}
            </Select>
            <Select
              value={
                trendingFilter === undefined ? "" : trendingFilter.toString()
              }
              onChange={(e) => {
                const value = e.target.value;
                setTrendingFilter(value === "" ? undefined : value === "true");
                setPage(0);
              }}
            >
              <option value="">All Events</option>
              <option value="true">Trending Only</option>
              <option value="false">Non-Trending</option>
            </Select>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>City</TableHead>
                <TableHead>Start Date</TableHead>
                <TableHead>Price Range</TableHead>
                <TableHead>Available</TableHead>
                <TableHead>Trending</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {events.map((event) => (
                <TableRow key={event.id}>
                  <TableCell className="font-medium">{event.name}</TableCell>
                  <TableCell>{event.category?.name || "-"}</TableCell>
                  <TableCell>{event.city?.name || "-"}</TableCell>
                  <TableCell>
                    {event.startDate
                      ? format(new Date(event.startDate), "MMM dd, yyyy")
                      : "-"}
                  </TableCell>
                  <TableCell>
                    {event.minPrice && event.maxPrice
                      ? `${event.minPrice} - ${event.maxPrice} ${
                          event.currency || ""
                        }`
                      : "-"}
                  </TableCell>
                  <TableCell>{event.availableTickets || 0}</TableCell>
                  <TableCell>
                    {event.isTrending ? (
                      <span className="text-primary font-semibold">Yes</span>
                    ) : (
                      <span className="text-muted-foreground">No</span>
                    )}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleView(event.id)}
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                      {canManageEvents() && (
                        <>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEdit(event.id)}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(event.id)}
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

      <div className="flex justify-between items-center">
        <Button
          variant="outline"
          disabled={page === 0}
          onClick={() => setPage(page - 1)}
        >
          Previous
        </Button>
        <span className="text-sm text-muted-foreground">
          Page {page + 1} of {totalPages || 1}
        </span>
        <Button
          variant="outline"
          disabled={page >= totalPages - 1}
          onClick={() => setPage(page + 1)}
        >
          Next
        </Button>
      </div>

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {editingEvent ? "Edit Event" : "Create Event"}
            </DialogTitle>
            <DialogDescription>
              {editingEvent
                ? "Update event information"
                : "Add a new event to the system"}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit}>
            <div className="space-y-4 py-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="name">Event Name *</Label>
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
                  <Label htmlFor="slug">Slug *</Label>
                  <Input
                    id="slug"
                    value={formData.slug}
                    onChange={(e) =>
                      setFormData({ ...formData, slug: e.target.value })
                    }
                    required
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) =>
                    setFormData({ ...formData, description: e.target.value })
                  }
                  rows={3}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="longDescription">Long Description</Label>
                <Textarea
                  id="longDescription"
                  value={formData.longDescription}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      longDescription: e.target.value,
                    })
                  }
                  rows={5}
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="categoryId">Category *</Label>
                  <Select
                    id="categoryId"
                    value={formData.categoryId}
                    onChange={(e) =>
                      setFormData({ ...formData, categoryId: e.target.value })
                    }
                    required
                  >
                    <option value="">Select category</option>
                    {categories.map((cat) => (
                      <option key={cat.id} value={cat.id}>
                        {cat.name}
                      </option>
                    ))}
                  </Select>
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
                    <option value="">Select city</option>
                    {cities.map((city) => (
                      <option key={city.id} value={city.id}>
                        {city.name}
                      </option>
                    ))}
                  </Select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="venueId">Venue</Label>
                  <Select
                    id="venueId"
                    value={formData.venueId}
                    onChange={(e) => {
                      const venue = venues.find((v) => v.id === e.target.value);
                      setFormData({
                        ...formData,
                        venueId: e.target.value,
                        venueName: venue?.name || "",
                        venueAddress: venue?.address || "",
                      });
                    }}
                  >
                    <option value="">Select venue</option>
                    {venues.map((venue) => (
                      <option key={venue.id} value={venue.id}>
                        {venue.name}
                      </option>
                    ))}
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="venueName">Venue Name (if not in list)</Label>
                  <Input
                    id="venueName"
                    value={formData.venueName}
                    onChange={(e) =>
                      setFormData({ ...formData, venueName: e.target.value })
                    }
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="venueAddress">Venue Address</Label>
                <Input
                  id="venueAddress"
                  value={formData.venueAddress}
                  onChange={(e) =>
                    setFormData({ ...formData, venueAddress: e.target.value })
                  }
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="startDate">Start Date *</Label>
                  <Input
                    id="startDate"
                    type="datetime-local"
                    value={formData.startDate}
                    onChange={(e) =>
                      setFormData({ ...formData, startDate: e.target.value })
                    }
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="endDate">End Date</Label>
                  <Input
                    id="endDate"
                    type="datetime-local"
                    value={formData.endDate}
                    onChange={(e) =>
                      setFormData({ ...formData, endDate: e.target.value })
                    }
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="currency">Currency</Label>
                  <Input
                    id="currency"
                    value={formData.currency}
                    onChange={(e) =>
                      setFormData({ ...formData, currency: e.target.value })
                    }
                  />
                </div>
                <div className="space-y-2 flex items-center">
                  <Checkbox
                    id="isTrending"
                    checked={formData.isTrending}
                    onCheckedChange={(checked: boolean) =>
                      setFormData({ ...formData, isTrending: checked })
                    }
                  />
                  <Label htmlFor="isTrending" className="ml-2 cursor-pointer">
                    Trending Event
                  </Label>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="thumbnail">Thumbnail URL</Label>
                <Input
                  id="thumbnail"
                  value={formData.thumbnail}
                  onChange={(e) =>
                    setFormData({ ...formData, thumbnail: e.target.value })
                  }
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="organizerName">Organizer Name</Label>
                <Input
                  id="organizerName"
                  value={formData.organizerName}
                  onChange={(e) =>
                    setFormData({ ...formData, organizerName: e.target.value })
                  }
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="organizerLogo">Organizer Logo URL</Label>
                <Input
                  id="organizerLogo"
                  value={formData.organizerLogo}
                  onChange={(e) =>
                    setFormData({ ...formData, organizerLogo: e.target.value })
                  }
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="terms">Terms & Conditions</Label>
                <Textarea
                  id="terms"
                  value={formData.terms}
                  onChange={(e) =>
                    setFormData({ ...formData, terms: e.target.value })
                  }
                  rows={3}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="cancellationPolicy">Cancellation Policy</Label>
                <Textarea
                  id="cancellationPolicy"
                  value={formData.cancellationPolicy}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      cancellationPolicy: e.target.value,
                    })
                  }
                  rows={3}
                />
              </div>

              {/* Ticket Types */}
              <div className="space-y-4 border-t pt-4">
                <div className="flex justify-between items-center">
                  <Label className="text-lg font-semibold">Ticket Types</Label>
                </div>
                {ticketTypes.map((tt, index) => (
                  <div key={index} className="border rounded p-3 space-y-2">
                    <div className="flex justify-between items-start">
                      <div className="flex-1 grid grid-cols-2 gap-2">
                        <div>
                          <span className="font-medium">{tt.name}</span>
                          <p className="text-sm text-muted-foreground">
                            {tt.description}
                          </p>
                        </div>
                        <div className="text-right">
                          <span className="font-medium">
                            {tt.price} {tt.currency}
                          </span>
                          <p className="text-sm text-muted-foreground">
                            Available: {tt.available} | Max per order:{" "}
                            {tt.maxPerOrder}
                          </p>
                        </div>
                      </div>
                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        onClick={() => removeTicketType(index)}
                      >
                        <X className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))}
                <div className="border rounded p-3 space-y-2">
                  <div className="grid grid-cols-2 gap-2">
                    <Input
                      placeholder="Ticket name *"
                      value={newTicketType.name}
                      onChange={(e) =>
                        setNewTicketType({
                          ...newTicketType,
                          name: e.target.value,
                        })
                      }
                    />
                    <Input
                      type="number"
                      placeholder="Price *"
                      value={newTicketType.price || ""}
                      onChange={(e) =>
                        setNewTicketType({
                          ...newTicketType,
                          price: parseInt(e.target.value) || 0,
                        })
                      }
                    />
                  </div>
                  <Textarea
                    placeholder="Description"
                    value={newTicketType.description}
                    onChange={(e) =>
                      setNewTicketType({
                        ...newTicketType,
                        description: e.target.value,
                      })
                    }
                    rows={2}
                  />
                  <div className="grid grid-cols-3 gap-2">
                    <Input
                      type="number"
                      placeholder="Available *"
                      value={newTicketType.available || ""}
                      onChange={(e) =>
                        setNewTicketType({
                          ...newTicketType,
                          available: parseInt(e.target.value) || 0,
                        })
                      }
                    />
                    <Input
                      type="number"
                      placeholder="Max per order"
                      value={newTicketType.maxPerOrder || ""}
                      onChange={(e) =>
                        setNewTicketType({
                          ...newTicketType,
                          maxPerOrder: parseInt(e.target.value) || 1,
                        })
                      }
                    />
                    <div className="flex items-center space-x-2">
                      <Checkbox
                        checked={newTicketType.requiresSeatSelection}
                        onCheckedChange={(checked: boolean) =>
                          setNewTicketType({
                            ...newTicketType,
                            requiresSeatSelection: checked,
                          })
                        }
                      />
                      <Label className="text-sm">Requires seat selection</Label>
                    </div>
                  </div>
                  <Button
                    type="button"
                    onClick={addTicketType}
                    variant="outline"
                    className="w-full"
                  >
                    Add Ticket Type
                  </Button>
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setDialogOpen(false)}
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
            <DialogTitle>{viewingEvent?.name}</DialogTitle>
            <DialogDescription>{viewingEvent?.description}</DialogDescription>
          </DialogHeader>
          {viewingEvent && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-muted-foreground">Category</Label>
                  <p>{viewingEvent.category?.name || "-"}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">City</Label>
                  <p>{viewingEvent.city?.name || "-"}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Start Date</Label>
                  <p>
                    {viewingEvent.startDate
                      ? format(new Date(viewingEvent.startDate), "PPpp")
                      : "-"}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">End Date</Label>
                  <p>
                    {viewingEvent.endDate
                      ? format(new Date(viewingEvent.endDate), "PPpp")
                      : "-"}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Price Range</Label>
                  <p>
                    {viewingEvent.minPrice && viewingEvent.maxPrice
                      ? `${viewingEvent.minPrice} - ${viewingEvent.maxPrice} ${
                          viewingEvent.currency || ""
                        }`
                      : "-"}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">
                    Available Tickets
                  </Label>
                  <p>{viewingEvent.availableTickets || 0}</p>
                </div>
              </div>
              {viewingEvent.longDescription && (
                <div>
                  <Label className="text-muted-foreground">
                    Long Description
                  </Label>
                  <p className="whitespace-pre-wrap">
                    {viewingEvent.longDescription}
                  </p>
                </div>
              )}
              {viewingEvent.ticketTypes &&
                viewingEvent.ticketTypes.length > 0 && (
                  <div>
                    <Label className="text-muted-foreground">
                      Ticket Types
                    </Label>
                    <div className="space-y-2 mt-2">
                      {viewingEvent.ticketTypes.map((tt, index) => (
                        <div key={index} className="border rounded p-3">
                          <div className="flex justify-between">
                            <div>
                              <p className="font-medium">{tt.name}</p>
                              <p className="text-sm text-muted-foreground">
                                {tt.description}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-medium">
                                {tt.price} {tt.currency}
                              </p>
                              <p className="text-sm text-muted-foreground">
                                Available: {tt.available} | Max:{" "}
                                {tt.maxPerOrder}
                              </p>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

              {/* Seating Chart */}
              {viewingEvent.venueId && (
                <div className="border-t pt-4">
                  <div className="flex justify-between items-center mb-4">
                    <Label className="text-lg font-semibold">
                      Seating Chart
                    </Label>
                    {loadingSeating && (
                      <span className="text-sm text-muted-foreground">
                        Loading...
                      </span>
                    )}
                  </div>

                  {seating &&
                  seating.sections &&
                  seating.sections.length > 0 ? (
                    <div className="space-y-6">
                      {seating.sections.map(
                        (section: any, sectionIndex: number) => (
                          <div
                            key={sectionIndex}
                            className="border rounded-lg p-4 bg-card"
                          >
                            <h3 className="font-semibold mb-3 text-lg">
                              {section.sectionName}
                            </h3>
                            {section.rows && section.rows.length > 0 ? (
                              <div className="space-y-4">
                                {section.rows.map(
                                  (row: any, rowIndex: number) => (
                                    <div key={rowIndex} className="space-y-2">
                                      <div className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                                        <span>Row {row.rowName}</span>
                                      </div>
                                      <div className="flex flex-wrap gap-1">
                                        {row.seats &&
                                          row.seats.map((seat: any) => (
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

                      {/* Legend */}
                      <div className="flex gap-4 flex-wrap pt-2 border-t">
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
                  ) : seating && !loadingSeating ? (
                    <p className="text-sm text-muted-foreground">
                      No seating chart available for this event
                    </p>
                  ) : null}
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
