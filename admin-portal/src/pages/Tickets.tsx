import { useEffect, useState } from "react";
import {
  ticketApi,
  adminTicketApi,
  TicketResponse,
  TicketDetailResponse,
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
import { Eye, X } from "lucide-react";
import { format } from "date-fns";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { usePermissions } from "@/hooks/usePermissions";

export default function Tickets() {
  const { isAdmin } = usePermissions();
  const [tickets, setTickets] = useState<TicketResponse[]>([]);
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
  const [selectedTicket, setSelectedTicket] =
    useState<TicketDetailResponse | null>(null);
  const [cancellingTicket, setCancellingTicket] =
    useState<TicketResponse | null>(null);
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
      alert("Failed to load ticket details");
    }
  };

  const handleCancel = (ticket: TicketResponse) => {
    if (ticket.status !== "ACTIVE") {
      alert("Only active tickets can be cancelled");
      return;
    }
    setCancellingTicket(ticket);
    setCancelReason("");
    setCancelDialogOpen(true);
  };

  const confirmCancel = async () => {
    if (!cancellingTicket) return;
    try {
      await ticketApi.cancelTicket(cancellingTicket.id, {
        reason: cancelReason || undefined,
      });
      setCancelDialogOpen(false);
      loadTickets();
    } catch (error) {
      console.error("Failed to cancel ticket:", error);
      const errorMessage =
        error instanceof Error ? error.message : "Failed to cancel ticket";
      alert(errorMessage);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "ACTIVE":
        return "text-green-600 bg-green-50";
      case "USED":
        return "text-blue-600 bg-blue-50";
      case "CANCELLED":
        return "text-red-600 bg-red-50";
      case "REFUNDED":
        return "text-purple-600 bg-purple-50";
      default:
        return "text-gray-600 bg-gray-50";
    }
  };

  if (loading && tickets.length === 0) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">
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
          <div className="flex gap-4 flex-wrap">
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
            {isAdmin() && (
              <>
                <Input
                  placeholder="Filter by User ID"
                  value={userIdFilter}
                  onChange={(e) => {
                    setUserIdFilter(e.target.value);
                    setPage(0);
                  }}
                  className="max-w-xs"
                />
                <Input
                  placeholder="Filter by Event ID"
                  value={eventIdFilter}
                  onChange={(e) => {
                    setEventIdFilter(e.target.value);
                    setPage(0);
                  }}
                  className="max-w-xs"
                />
              </>
            )}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Event</TableHead>
                <TableHead>Ticket Type</TableHead>
                <TableHead>Seat</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Purchase Date</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {tickets.map((ticket) => (
                <TableRow key={ticket.id}>
                  <TableCell className="font-medium">
                    {ticket.eventName}
                  </TableCell>
                  <TableCell>{ticket.ticketTypeName}</TableCell>
                  <TableCell>{ticket.seatNumber || "-"}</TableCell>
                  <TableCell>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(
                        ticket.status
                      )}`}
                    >
                      {ticket.status}
                    </span>
                  </TableCell>
                  <TableCell>
                    {format(new Date(ticket.purchaseDate), "MMM dd, yyyy")}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleView(ticket.id)}
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                      {ticket.status === "ACTIVE" && isAdmin() && (
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleCancel(ticket)}
                        >
                          <X className="h-4 w-4 text-destructive" />
                        </Button>
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

      {/* View Dialog */}
      <Dialog open={viewDialogOpen} onOpenChange={setViewDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Ticket Details</DialogTitle>
            <DialogDescription>{selectedTicket?.eventName}</DialogDescription>
          </DialogHeader>
          {selectedTicket && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-muted-foreground">Ticket ID</Label>
                  <p className="font-mono text-sm">{selectedTicket.id}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Status</Label>
                  <p>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(
                        selectedTicket.status
                      )}`}
                    >
                      {selectedTicket.status}
                    </span>
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Ticket Type</Label>
                  <p>{selectedTicket.ticketTypeName}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Price</Label>
                  <p>{selectedTicket.ticketTypePrice}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Seat Number</Label>
                  <p>{selectedTicket.seatNumber || "-"}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Venue</Label>
                  <p>{selectedTicket.venueName || "-"}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Event Start</Label>
                  <p>
                    {format(new Date(selectedTicket.eventStartDate), "PPpp")}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Purchase Date</Label>
                  <p>{format(new Date(selectedTicket.purchaseDate), "PPpp")}</p>
                </div>
                {selectedTicket.checkedInAt && (
                  <div>
                    <Label className="text-muted-foreground">Checked In</Label>
                    <p>
                      {format(new Date(selectedTicket.checkedInAt), "PPpp")}
                    </p>
                  </div>
                )}
                {selectedTicket.cancelledAt && (
                  <div>
                    <Label className="text-muted-foreground">
                      Cancelled At
                    </Label>
                    <p>
                      {format(new Date(selectedTicket.cancelledAt), "PPpp")}
                    </p>
                  </div>
                )}
                {selectedTicket.refundAmount && (
                  <div>
                    <Label className="text-muted-foreground">
                      Refund Amount
                    </Label>
                    <p>{selectedTicket.refundAmount}</p>
                  </div>
                )}
                {selectedTicket.refundStatus && (
                  <div>
                    <Label className="text-muted-foreground">
                      Refund Status
                    </Label>
                    <p>{selectedTicket.refundStatus}</p>
                  </div>
                )}
              </div>
              {selectedTicket.cancellationReason && (
                <div>
                  <Label className="text-muted-foreground">
                    Cancellation Reason
                  </Label>
                  <p>{selectedTicket.cancellationReason}</p>
                </div>
              )}
              {selectedTicket.qrCodeImage && (
                <div>
                  <Label className="text-muted-foreground">QR Code</Label>
                  <img
                    src={selectedTicket.qrCodeImage}
                    alt="QR Code"
                    className="mt-2 border rounded"
                  />
                </div>
              )}
            </div>
          )}
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
