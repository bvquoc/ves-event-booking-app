import { useEffect, useState } from "react";
import {
  ticketApi,
  adminTicketApi,
  TicketResponse,
  TicketDetailResponse,
  AdminTicketResponse,
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
import {
  Eye,
  X,
  Ticket,
  User,
  Calendar,
  MapPin,
  Tag,
  Filter,
  Search,
  ChevronLeft,
  ChevronRight,
  CheckCircle2,
  XCircle,
  Clock,
  RefreshCw,
  Package,
  CreditCard,
  QrCode,
} from "lucide-react";
import { format } from "date-fns";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { showError, showSuccess, showWarning } from "@/lib/errorHandler";
import { QRCodeSVG } from "qrcode.react";
import { Input } from "@/components/ui/input";
import { usePermissions } from "@/hooks/usePermissions";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";

export default function Tickets() {
  const { isAdmin } = usePermissions();
  const [tickets, setTickets] = useState<
    (TicketResponse | AdminTicketResponse)[]
  >([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [statusFilter, setStatusFilter] = useState<
    "ACTIVE" | "USED" | "CANCELLED" | "REFUNDED" | ""
  >("");
  const [userIdFilter, setUserIdFilter] = useState("");
  const [eventIdFilter, setEventIdFilter] = useState("");
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [cancelDialogOpen, setCancelDialogOpen] = useState(false);
  const [selectedTicket, setSelectedTicket] = useState<
    TicketDetailResponse | AdminTicketResponse | null
  >(null);
  const [cancellingTicket, setCancellingTicket] = useState<
    TicketResponse | AdminTicketResponse | null
  >(null);
  const [cancelReason, setCancelReason] = useState("");

  const loadTickets = async () => {
    try {
      setLoading(true);
      const params: {
        pageable: { page: number; size: number };
        status?: "ACTIVE" | "USED" | "CANCELLED" | "REFUNDED";
        userId?: string;
        eventId?: string;
      } = {
        pageable: { page, size: 10 },
      };
      if (statusFilter) {
        params.status = statusFilter;
      }

      let response;
      if (isAdmin()) {
        // Use admin endpoint with additional filters
        if (userIdFilter) {
          params.userId = userIdFilter;
        }
        if (eventIdFilter) {
          params.eventId = eventIdFilter;
        }
        response = await adminTicketApi.getAllTickets(params);
      } else {
        // Use regular user endpoint
        response = await ticketApi.getTickets(params);
      }

      setTickets(response.result.content);
      setTotalPages(response.result.totalPages);
      setTotalElements(response.result.totalElements);
    } catch (error) {
      console.error("Failed to load tickets:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTickets();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, statusFilter, userIdFilter, eventIdFilter]);

  const handleView = async (ticketId: string) => {
    try {
      const response = isAdmin()
        ? await adminTicketApi.getTicketDetails(ticketId)
        : await ticketApi.getTicketDetails(ticketId);
      setSelectedTicket(response.result);
      setViewDialogOpen(true);
    } catch (error) {
      console.error("Failed to load ticket details:", error);
      showError(error);
    }
  };

  const handleCancel = (ticket: TicketResponse | AdminTicketResponse) => {
    if (ticket.status !== "ACTIVE") {
      showWarning("Only active tickets can be cancelled");
      return;
    }
    setCancellingTicket(ticket);
    setCancelReason("");
    setCancelDialogOpen(true);
  };

  const confirmCancel = async () => {
    if (!cancellingTicket) return;
    try {
      const ticketId = cancellingTicket.id;
      await ticketApi.cancelTicket(ticketId, {
        reason: cancelReason || undefined,
      });
      setCancelDialogOpen(false);
      showSuccess("Ticket cancelled successfully");
      loadTickets();
    } catch (error) {
      console.error("Failed to cancel ticket:", error);
      showError(error);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "ACTIVE":
        return (
          <Badge
            variant="outline"
            className="bg-green-50 text-green-700 border-green-200"
          >
            <CheckCircle2 className="h-3 w-3 mr-1" />
            Active
          </Badge>
        );
      case "USED":
        return (
          <Badge
            variant="outline"
            className="bg-blue-50 text-blue-700 border-blue-200"
          >
            <CheckCircle2 className="h-3 w-3 mr-1" />
            Used
          </Badge>
        );
      case "CANCELLED":
        return (
          <Badge
            variant="outline"
            className="bg-red-50 text-red-700 border-red-200"
          >
            <XCircle className="h-3 w-3 mr-1" />
            Cancelled
          </Badge>
        );
      case "REFUNDED":
        return (
          <Badge
            variant="outline"
            className="bg-purple-50 text-purple-700 border-purple-200"
          >
            <RefreshCw className="h-3 w-3 mr-1" />
            Refunded
          </Badge>
        );
      default:
        return (
          <Badge
            variant="outline"
            className="bg-gray-50 text-gray-700 border-gray-200"
          >
            {status}
          </Badge>
        );
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("vi-VN").format(amount) + " đ";
  };

  if (loading && tickets.length === 0) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6 w-full max-w-full">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2">
            <Ticket className="h-8 w-8" />
            {isAdmin() ? "Tickets" : "My Tickets"}
          </h1>
          <p className="text-muted-foreground">
            {isAdmin() ? "Manage all tickets" : "View your tickets"} (
            {totalElements} total)
          </p>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex items-center gap-2 mb-4">
            <Filter className="h-4 w-4 text-muted-foreground" />
            <h3 className="font-semibold">Filters</h3>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">
                Status
              </Label>
              <Select
                value={statusFilter}
                onChange={(e) => {
                  setStatusFilter(
                    e.target.value as
                      | "ACTIVE"
                      | "USED"
                      | "CANCELLED"
                      | "REFUNDED"
                      | ""
                  );
                  setPage(0);
                }}
              >
                <option value="">All Statuses</option>
                <option value="ACTIVE">Active</option>
                <option value="USED">Used</option>
                <option value="CANCELLED">Cancelled</option>
                <option value="REFUNDED">Refunded</option>
              </Select>
            </div>
            {isAdmin() && (
              <>
                <div>
                  <Label className="text-xs text-muted-foreground mb-1 block">
                    User ID
                  </Label>
                  <div className="relative">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Filter by User ID"
                      value={userIdFilter}
                      onChange={(e) => {
                        setUserIdFilter(e.target.value);
                        setPage(0);
                      }}
                      className="pl-8"
                    />
                  </div>
                </div>
                <div>
                  <Label className="text-xs text-muted-foreground mb-1 block">
                    Event ID
                  </Label>
                  <div className="relative">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Filter by Event ID"
                      value={eventIdFilter}
                      onChange={(e) => {
                        setEventIdFilter(e.target.value);
                        setPage(0);
                      }}
                      className="pl-8"
                    />
                  </div>
                </div>
              </>
            )}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto w-full">
            <Table className="w-full">
              <TableHeader>
                <TableRow>
                  {isAdmin() && (
                    <TableHead className="min-w-[200px]">User</TableHead>
                  )}
                  <TableHead className="min-w-[180px]">Event</TableHead>
                  <TableHead className="min-w-[140px]">Ticket Type</TableHead>
                  <TableHead className="min-w-[140px]">Seat</TableHead>
                  <TableHead className="min-w-[120px]">Status</TableHead>
                  <TableHead className="min-w-[140px]">Purchase Date</TableHead>
                  <TableHead className="text-right min-w-[100px]">
                    Actions
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {tickets.map((ticket) => {
                  const isAdminTicket = "user" in ticket;
                  const eventName = isAdminTicket
                    ? ticket.event.name
                    : ticket.eventName;
                  const ticketTypeName = isAdminTicket
                    ? ticket.ticketType.name
                    : ticket.ticketTypeName;
                  // For admin tickets, seat info is in ticket.seat (optional)
                  // For regular tickets, seat info is in ticket.seatNumber (optional)
                  // Seat can be null if:
                  // 1. Ticket type doesn't require seat selection (general admission)
                  // 2. Seat hasn't been assigned yet
                  let seatDisplay = "General admission";
                  if (isAdminTicket) {
                    if (ticket.seat) {
                      // Show full seat info: Section - Row - SeatNumber
                      const parts = [
                        ticket.seat.section,
                        ticket.seat.row,
                        ticket.seat.seatNumber,
                      ].filter(Boolean);
                      seatDisplay =
                        parts.length > 0
                          ? parts.join(" - ")
                          : "General admission";
                    }
                    // else: seatDisplay already set to "General admission"
                  } else if (ticket.seatNumber) {
                    seatDisplay = ticket.seatNumber;
                  }
                  // else: seatDisplay already set to "General admission"
                  const purchaseDate = ticket.purchaseDate;

                  return (
                    <TableRow key={ticket.id} className="hover:bg-muted/50">
                      {isAdmin() && (
                        <TableCell>
                          {isAdminTicket ? (
                            <div className="flex items-center gap-3">
                              <Avatar className="h-8 w-8">
                                <AvatarImage
                                  src={`https://api.dicebear.com/7.x/initials/svg?seed=${
                                    ticket.user.fullName || ticket.user.username
                                  }`}
                                  alt="Avatar"
                                />
                                <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                                  {(
                                    ticket.user.fullName || ticket.user.username
                                  )
                                    .charAt(0)
                                    .toUpperCase()}
                                </AvatarFallback>
                              </Avatar>
                              <div>
                                <div className="font-medium">
                                  {ticket.user.fullName || ticket.user.username}
                                </div>
                                <div className="text-xs text-muted-foreground">
                                  {ticket.user.email}
                                </div>
                              </div>
                            </div>
                          ) : (
                            "-"
                          )}
                        </TableCell>
                      )}
                      <TableCell className="font-medium">
                        <div className="flex items-center gap-2">
                          <Calendar className="h-4 w-4 text-muted-foreground" />
                          <span>{eventName}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Tag className="h-3 w-3 text-muted-foreground" />
                          <span>{ticketTypeName}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <MapPin className="h-3 w-3 text-muted-foreground" />
                          <span className="text-sm">{seatDisplay}</span>
                        </div>
                      </TableCell>
                      <TableCell>{getStatusBadge(ticket.status)}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2 text-sm">
                          <Clock className="h-4 w-4 text-muted-foreground" />
                          <span>
                            {format(new Date(purchaseDate), "MMM dd, yyyy")}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleView(ticket.id)}
                            title="View Details"
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          {ticket.status === "ACTIVE" && isAdmin() && (
                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => handleCancel(ticket)}
                              title="Cancel Ticket"
                            >
                              <X className="h-4 w-4 text-destructive" />
                            </Button>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-between items-center">
        <Button
          variant="outline"
          disabled={page === 0}
          onClick={() => setPage(page - 1)}
        >
          <ChevronLeft className="h-4 w-4 mr-2" />
          Previous
        </Button>
        <span className="text-sm text-muted-foreground">
          Page {page + 1} of {totalPages || 1} ({totalElements} total tickets)
        </span>
        <Button
          variant="outline"
          disabled={page >= totalPages - 1}
          onClick={() => setPage(page + 1)}
        >
          Next
          <ChevronRight className="h-4 w-4 ml-2" />
        </Button>
      </div>

      {/* View Dialog */}
      <Dialog open={viewDialogOpen} onOpenChange={setViewDialogOpen}>
        <DialogContent className="max-w-[95vw] sm:max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Ticket className="h-5 w-5" />
              Ticket Details
            </DialogTitle>
            <DialogDescription>
              {selectedTicket && "event" in selectedTicket
                ? selectedTicket.event.name
                : selectedTicket?.eventName}
            </DialogDescription>
          </DialogHeader>
          {selectedTicket && (
            <div className="space-y-6">
              {/* Ticket Summary */}
              <div className="bg-muted/50 p-4 rounded-lg border">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Ticket ID
                    </Label>
                    <p className="font-mono text-sm font-semibold">
                      {selectedTicket.id}
                    </p>
                  </div>
                  <div>{getStatusBadge(selectedTicket.status)}</div>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Ticket Type
                    </Label>
                    <p className="font-medium flex items-center gap-2">
                      <Tag className="h-4 w-4 text-muted-foreground" />
                      {"ticketType" in selectedTicket
                        ? selectedTicket.ticketType.name
                        : selectedTicket.ticketTypeName}
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Price
                    </Label>
                    <p className="font-semibold">
                      {"ticketType" in selectedTicket
                        ? formatCurrency(selectedTicket.ticketType.price)
                        : selectedTicket.ticketTypePrice}
                    </p>
                  </div>
                </div>
              </div>

              {isAdmin() && "user" in selectedTicket && (
                <div className="border rounded-lg p-4">
                  <h3 className="font-semibold mb-4 flex items-center gap-2">
                    <User className="h-4 w-4" />
                    User Information
                  </h3>
                  <div className="flex items-start gap-4">
                    <Avatar className="h-12 w-12">
                      <AvatarImage
                        src={`https://api.dicebear.com/7.x/initials/svg?seed=${
                          selectedTicket.user.fullName ||
                          selectedTicket.user.username
                        }`}
                        alt="Avatar"
                      />
                      <AvatarFallback className="bg-primary text-primary-foreground">
                        {(
                          selectedTicket.user.fullName ||
                          selectedTicket.user.username
                        )
                          .charAt(0)
                          .toUpperCase()}
                      </AvatarFallback>
                    </Avatar>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 flex-1">
                      <div>
                        <Label className="text-xs text-muted-foreground">
                          Name
                        </Label>
                        <p className="font-medium">
                          {selectedTicket.user.fullName ||
                            selectedTicket.user.username}
                        </p>
                      </div>
                      <div>
                        <Label className="text-xs text-muted-foreground">
                          Email
                        </Label>
                        <p className="break-words">
                          {selectedTicket.user.email}
                        </p>
                      </div>
                      <div>
                        <Label className="text-xs text-muted-foreground">
                          Phone
                        </Label>
                        <p>{selectedTicket.user.phone || "-"}</p>
                      </div>
                      <div>
                        <Label className="text-xs text-muted-foreground">
                          User ID
                        </Label>
                        <p className="font-mono text-xs break-all">
                          {selectedTicket.user.id}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Event Information */}
              <div className="border rounded-lg p-4">
                <h3 className="font-semibold mb-4 flex items-center gap-2">
                  <Calendar className="h-4 w-4" />
                  Event Information
                </h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Event Name
                    </Label>
                    <p className="font-medium break-words">
                      {"event" in selectedTicket
                        ? selectedTicket.event.name
                        : selectedTicket.eventName}
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Venue
                    </Label>
                    <p className="flex items-center gap-2">
                      <MapPin className="h-3 w-3 text-muted-foreground" />
                      {"event" in selectedTicket
                        ? selectedTicket.event.venueName || "-"
                        : "venueName" in selectedTicket
                        ? selectedTicket.venueName || "-"
                        : "-"}
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Event Start
                    </Label>
                    <p className="flex items-center gap-1">
                      <Clock className="h-3 w-3 text-muted-foreground" />
                      {format(
                        new Date(
                          "event" in selectedTicket
                            ? selectedTicket.event.startDate
                            : selectedTicket.eventStartDate
                        ),
                        "PPpp"
                      )}
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Purchase Date
                    </Label>
                    <p className="flex items-center gap-1">
                      <Clock className="h-3 w-3 text-muted-foreground" />
                      {format(new Date(selectedTicket.purchaseDate), "PPpp")}
                    </p>
                  </div>
                </div>
              </div>

              {/* Seat Information */}
              <div className="border rounded-lg p-4">
                <h3 className="font-semibold mb-4 flex items-center gap-2">
                  <MapPin className="h-4 w-4" />
                  Seat Information
                </h3>
                <div>
                  <Label className="text-xs text-muted-foreground">Seat</Label>
                  <p className="font-medium">
                    {"seat" in selectedTicket && selectedTicket.seat ? (
                      <span>
                        {selectedTicket.seat.section &&
                          `${selectedTicket.seat.section} - `}
                        {selectedTicket.seat.row &&
                          `${selectedTicket.seat.row} - `}
                        {selectedTicket.seat.seatNumber}
                      </span>
                    ) : "seatNumber" in selectedTicket &&
                      selectedTicket.seatNumber ? (
                      selectedTicket.seatNumber
                    ) : (
                      <span className="text-muted-foreground italic">
                        General admission / No seat assigned
                      </span>
                    )}
                  </p>
                </div>
              </div>

              {/* Order Information (Admin only) */}
              {isAdmin() && "order" in selectedTicket && (
                <div className="border rounded-lg p-4">
                  <h3 className="font-semibold mb-4 flex items-center gap-2">
                    <Package className="h-4 w-4" />
                    Order Information
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Order ID
                      </Label>
                      <p className="font-mono text-xs break-all">
                        {selectedTicket.order.id}
                      </p>
                    </div>
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Order Status
                      </Label>
                      <p>{selectedTicket.order.status}</p>
                    </div>
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Payment Method
                      </Label>
                      <p className="flex items-center gap-2">
                        <CreditCard className="h-3 w-3 text-muted-foreground" />
                        {selectedTicket.order.paymentMethod}
                      </p>
                    </div>
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Order Total
                      </Label>
                      <p className="font-semibold">
                        {formatCurrency(selectedTicket.order.total)}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {/* Timestamps */}
              {(("checkedInAt" in selectedTicket &&
                selectedTicket.checkedInAt) ||
                ("cancelledAt" in selectedTicket &&
                  selectedTicket.cancelledAt) ||
                ("refundAmount" in selectedTicket &&
                  selectedTicket.refundAmount)) && (
                <div className="border rounded-lg p-4">
                  <h3 className="font-semibold mb-4 flex items-center gap-2">
                    <Clock className="h-4 w-4" />
                    Additional Information
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {"checkedInAt" in selectedTicket &&
                      selectedTicket.checkedInAt && (
                        <div>
                          <Label className="text-xs text-muted-foreground">
                            Checked In
                          </Label>
                          <p className="flex items-center gap-1">
                            <CheckCircle2 className="h-3 w-3 text-green-600" />
                            {format(
                              new Date(selectedTicket.checkedInAt),
                              "PPpp"
                            )}
                          </p>
                        </div>
                      )}
                    {"cancelledAt" in selectedTicket &&
                      selectedTicket.cancelledAt && (
                        <div>
                          <Label className="text-xs text-muted-foreground">
                            Cancelled At
                          </Label>
                          <p className="flex items-center gap-1">
                            <XCircle className="h-3 w-3 text-red-600" />
                            {format(
                              new Date(selectedTicket.cancelledAt),
                              "PPpp"
                            )}
                          </p>
                        </div>
                      )}
                    {"refundAmount" in selectedTicket &&
                      selectedTicket.refundAmount && (
                        <div>
                          <Label className="text-xs text-muted-foreground">
                            Refund Amount
                          </Label>
                          <p className="font-semibold">
                            {formatCurrency(selectedTicket.refundAmount)}
                          </p>
                        </div>
                      )}
                    {"refundStatus" in selectedTicket &&
                      selectedTicket.refundStatus && (
                        <div>
                          <Label className="text-xs text-muted-foreground">
                            Refund Status
                          </Label>
                          <p>{selectedTicket.refundStatus}</p>
                        </div>
                      )}
                  </div>
                </div>
              )}

              {"cancellationReason" in selectedTicket &&
                selectedTicket.cancellationReason && (
                  <div className="border rounded-lg p-4">
                    <h3 className="font-semibold mb-2 flex items-center gap-2">
                      <XCircle className="h-4 w-4 text-red-600" />
                      Cancellation Reason
                    </h3>
                    <p className="text-sm">
                      {selectedTicket.cancellationReason}
                    </p>
                  </div>
                )}

              {/* QR Code */}
              {("qrCode" in selectedTicket && selectedTicket.qrCode) ||
              ("qrCodeImage" in selectedTicket &&
                selectedTicket.qrCodeImage) ? (
                <div className="border rounded-lg p-4">
                  <h3 className="font-semibold mb-4 flex items-center gap-2">
                    <QrCode className="h-4 w-4" />
                    QR Code
                  </h3>
                  <div className="flex flex-col items-center gap-3">
                    {"qrCode" in selectedTicket && selectedTicket.qrCode ? (
                      <div className="border rounded-lg p-4 bg-white">
                        <QRCodeSVG
                          value={selectedTicket.qrCode}
                          size={200}
                          level="H"
                          includeMargin={true}
                        />
                      </div>
                    ) : null}
                    {"qrCodeImage" in selectedTicket &&
                    selectedTicket.qrCodeImage ? (
                      <img
                        src={selectedTicket.qrCodeImage}
                        alt="QR Code"
                        className="border rounded-lg"
                      />
                    ) : null}
                    {"qrCode" in selectedTicket && selectedTicket.qrCode && (
                      <p className="text-xs text-muted-foreground font-mono break-all bg-muted p-2 rounded">
                        {selectedTicket.qrCode}
                      </p>
                    )}
                  </div>
                </div>
              ) : null}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setViewDialogOpen(false)}>
              Close
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Cancel Dialog */}
      <Dialog open={cancelDialogOpen} onOpenChange={setCancelDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Cancel Ticket</DialogTitle>
            <DialogDescription>
              Are you sure you want to cancel this ticket?
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="reason">Cancellation Reason (Optional)</Label>
              <Textarea
                id="reason"
                value={cancelReason}
                onChange={(e) => setCancelReason(e.target.value)}
                rows={3}
                placeholder="Enter reason for cancellation..."
              />
            </div>
          </div>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => setCancelDialogOpen(false)}
            >
              Cancel
            </Button>
            <Button variant="destructive" onClick={confirmCancel}>
              Confirm Cancellation
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
