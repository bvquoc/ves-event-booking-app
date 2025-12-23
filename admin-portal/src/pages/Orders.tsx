import { useEffect, useState } from "react";
import { adminOrderApi, AdminOrderResponse } from "@/lib/api";
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
import { Eye } from "lucide-react";
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
import { Input } from "@/components/ui/input";
import { usePermissions } from "@/hooks/usePermissions";

export default function Orders() {
  const { isAdmin } = usePermissions();
  const [orders, setOrders] = useState<AdminOrderResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [statusFilter, setStatusFilter] = useState<
    "PENDING" | "COMPLETED" | "CANCELLED" | "EXPIRED" | "REFUNDED" | ""
  >("");
  const [userIdFilter, setUserIdFilter] = useState("");
  const [eventIdFilter, setEventIdFilter] = useState("");
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState<AdminOrderResponse | null>(
    null
  );

  const loadOrders = async () => {
    try {
      setLoading(true);
      const params: {
        pageable: { page: number; size: number };
        status?: "PENDING" | "COMPLETED" | "CANCELLED" | "EXPIRED" | "REFUNDED";
        userId?: string;
        eventId?: string;
      } = {
        pageable: { page, size: 10 },
      };
      if (statusFilter) {
        params.status = statusFilter;
      }
      if (userIdFilter) {
        params.userId = userIdFilter;
      }
      if (eventIdFilter) {
        params.eventId = eventIdFilter;
      }

      const response = await adminOrderApi.getAllOrders(params);
      setOrders(response.result.content);
      setTotalPages(response.result.totalPages);
      setTotalElements(response.result.totalElements);
    } catch (error) {
      console.error("Failed to load orders:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!isAdmin()) {
      return;
    }
    loadOrders();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, statusFilter, userIdFilter, eventIdFilter]);

  const handleView = async (orderId: string) => {
    try {
      const response = await adminOrderApi.getOrderDetails(orderId);
      setSelectedOrder(response.result);
      setViewDialogOpen(true);
    } catch (error) {
      console.error("Failed to load order details:", error);
      alert("Failed to load order details");
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "PENDING":
        return "text-yellow-600 bg-yellow-50";
      case "COMPLETED":
        return "text-green-600 bg-green-50";
      case "CANCELLED":
        return "text-red-600 bg-red-50";
      case "EXPIRED":
        return "text-gray-600 bg-gray-50";
      case "REFUNDED":
        return "text-purple-600 bg-purple-50";
      default:
        return "text-gray-600 bg-gray-50";
    }
  };

  const formatCurrency = (amount: number, currency: string = "VND") => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: currency,
    }).format(amount);
  };

  if (!isAdmin()) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Access Denied</h1>
          <p className="text-muted-foreground">
            You need admin privileges to view orders.
          </p>
        </div>
      </div>
    );
  }

  if (loading && orders.length === 0) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Orders</h1>
          <p className="text-muted-foreground">
            Manage all orders ({totalElements} total)
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
                    | "PENDING"
                    | "COMPLETED"
                    | "CANCELLED"
                    | "EXPIRED"
                    | "REFUNDED"
                    | ""
                );
                setPage(0);
              }}
            >
              <option value="">All Statuses</option>
              <option value="PENDING">Pending</option>
              <option value="COMPLETED">Completed</option>
              <option value="CANCELLED">Cancelled</option>
              <option value="EXPIRED">Expired</option>
              <option value="REFUNDED">Refunded</option>
            </Select>
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
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Order ID</TableHead>
                <TableHead>User</TableHead>
                <TableHead>Event</TableHead>
                <TableHead>Ticket Type</TableHead>
                <TableHead>Quantity</TableHead>
                <TableHead>Total</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Payment Method</TableHead>
                <TableHead>Created At</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {orders.map((order) => (
                <TableRow key={order.id}>
                  <TableCell className="font-mono text-xs">
                    {order.id.substring(0, 8)}...
                  </TableCell>
                  <TableCell>
                    <div>
                      <div className="font-medium">
                        {order.user.fullName || order.user.username}
                      </div>
                      <div className="text-xs text-muted-foreground">
                        {order.user.email}
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="font-medium">
                    {order.event.name}
                  </TableCell>
                  <TableCell>{order.ticketType.name}</TableCell>
                  <TableCell>{order.quantity}</TableCell>
                  <TableCell>
                    {formatCurrency(order.total, order.currency)}
                  </TableCell>
                  <TableCell>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(
                        order.status
                      )}`}
                    >
                      {order.status}
                    </span>
                  </TableCell>
                  <TableCell>{order.paymentMethod}</TableCell>
                  <TableCell>
                    {format(new Date(order.createdAt), "MMM dd, yyyy")}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => handleView(order.id)}
                    >
                      <Eye className="h-4 w-4" />
                    </Button>
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
            <DialogTitle>Order Details</DialogTitle>
            <DialogDescription>{selectedOrder?.event.name}</DialogDescription>
          </DialogHeader>
          {selectedOrder && (
            <div className="space-y-4">
              {/* User Information */}
              <div className="border-b pb-4">
                <h3 className="font-semibold mb-2">User Information</h3>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label className="text-muted-foreground">Name</Label>
                    <p>
                      {selectedOrder.user.fullName ||
                        selectedOrder.user.username}
                    </p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Email</Label>
                    <p>{selectedOrder.user.email}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Phone</Label>
                    <p>{selectedOrder.user.phone}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">User ID</Label>
                    <p className="font-mono text-xs">{selectedOrder.user.id}</p>
                  </div>
                </div>
              </div>

              {/* Event Information */}
              <div className="border-b pb-4">
                <h3 className="font-semibold mb-2">Event Information</h3>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label className="text-muted-foreground">Event Name</Label>
                    <p>{selectedOrder.event.name}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Event ID</Label>
                    <p className="font-mono text-xs">
                      {selectedOrder.event.id}
                    </p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Venue</Label>
                    <p>{selectedOrder.event.venueName || "-"}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Start Date</Label>
                    <p>
                      {format(new Date(selectedOrder.event.startDate), "PPpp")}
                    </p>
                  </div>
                </div>
              </div>

              {/* Order Information */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-muted-foreground">Order ID</Label>
                  <p className="font-mono text-sm">{selectedOrder.id}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Status</Label>
                  <p>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(
                        selectedOrder.status
                      )}`}
                    >
                      {selectedOrder.status}
                    </span>
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Ticket Type</Label>
                  <p>{selectedOrder.ticketType.name}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Quantity</Label>
                  <p>{selectedOrder.quantity}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Subtotal</Label>
                  <p>
                    {formatCurrency(
                      selectedOrder.subtotal,
                      selectedOrder.currency
                    )}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Discount</Label>
                  <p>
                    {formatCurrency(
                      selectedOrder.discount,
                      selectedOrder.currency
                    )}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Total</Label>
                  <p className="font-semibold">
                    {formatCurrency(
                      selectedOrder.total,
                      selectedOrder.currency
                    )}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Currency</Label>
                  <p>{selectedOrder.currency}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Status</Label>
                  <p>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(
                        selectedOrder.status
                      )}`}
                    >
                      {selectedOrder.status}
                    </span>
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">
                    Payment Method
                  </Label>
                  <p>{selectedOrder.paymentMethod}</p>
                </div>
                {selectedOrder.voucherCode && (
                  <div>
                    <Label className="text-muted-foreground">
                      Voucher Code
                    </Label>
                    <p>{selectedOrder.voucherCode}</p>
                  </div>
                )}
                <div>
                  <Label className="text-muted-foreground">Created At</Label>
                  <p>{format(new Date(selectedOrder.createdAt), "PPpp")}</p>
                </div>
                {selectedOrder.expiresAt && (
                  <div>
                    <Label className="text-muted-foreground">Expires At</Label>
                    <p>{format(new Date(selectedOrder.expiresAt), "PPpp")}</p>
                  </div>
                )}
                {selectedOrder.completedAt && (
                  <div>
                    <Label className="text-muted-foreground">
                      Completed At
                    </Label>
                    <p>{format(new Date(selectedOrder.completedAt), "PPpp")}</p>
                  </div>
                )}
                {selectedOrder.paymentUrl && (
                  <div className="col-span-2">
                    <Label className="text-muted-foreground">Payment URL</Label>
                    <p className="break-all text-sm">
                      {selectedOrder.paymentUrl}
                    </p>
                  </div>
                )}
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
