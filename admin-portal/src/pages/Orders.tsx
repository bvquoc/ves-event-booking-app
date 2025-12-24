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
import {
  Eye,
  ShoppingCart,
  User,
  Calendar,
  CreditCard,
  Filter,
  Search,
  ChevronLeft,
  ChevronRight,
  Package,
  Tag,
  Clock,
  CheckCircle2,
  XCircle,
  AlertCircle,
  RefreshCw,
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
import { Input } from "@/components/ui/input";
import { usePermissions } from "@/hooks/usePermissions";
import { showError } from "@/lib/errorHandler";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";

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
      showError(error);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "PENDING":
        return (
          <Badge
            variant="outline"
            className="bg-yellow-50 text-yellow-700 border-yellow-200"
          >
            <Clock className="h-3 w-3 mr-1" />
            Pending
          </Badge>
        );
      case "COMPLETED":
        return (
          <Badge
            variant="outline"
            className="bg-green-50 text-green-700 border-green-200"
          >
            <CheckCircle2 className="h-3 w-3 mr-1" />
            Completed
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
      case "EXPIRED":
        return (
          <Badge
            variant="outline"
            className="bg-gray-50 text-gray-700 border-gray-200"
          >
            <AlertCircle className="h-3 w-3 mr-1" />
            Expired
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
    <div className="space-y-6 w-full max-w-full">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2">
            <ShoppingCart className="h-8 w-8" />
            Orders
          </h1>
          <p className="text-muted-foreground">
            Manage all orders ({totalElements} total)
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
            </div>
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
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto w-full">
            <Table className="w-full">
              <TableHeader>
                <TableRow>
                  <TableHead className="min-w-[120px]">Order ID</TableHead>
                  <TableHead className="min-w-[200px]">User</TableHead>
                  <TableHead className="min-w-[180px]">Event</TableHead>
                  <TableHead className="min-w-[140px]">Ticket Type</TableHead>
                  <TableHead className="min-w-[100px]">Quantity</TableHead>
                  <TableHead className="min-w-[120px]">Total</TableHead>
                  <TableHead className="min-w-[120px]">Status</TableHead>
                  <TableHead className="min-w-[120px]">Payment</TableHead>
                  <TableHead className="min-w-[140px]">Created At</TableHead>
                  <TableHead className="text-right min-w-[80px]">
                    Actions
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {orders.map((order) => (
                  <TableRow key={order.id} className="hover:bg-muted/50">
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Package className="h-4 w-4 text-muted-foreground" />
                        <span className="font-mono text-xs font-semibold">
                          {order.id.substring(0, 8)}...
                        </span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Avatar className="h-8 w-8">
                          <AvatarImage
                            src={`https://api.dicebear.com/7.x/initials/svg?seed=${
                              order.user.fullName || order.user.username
                            }`}
                            alt="Avatar"
                          />
                          <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                            {(order.user.fullName || order.user.username)
                              .charAt(0)
                              .toUpperCase()}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">
                            {order.user.fullName || order.user.username}
                          </div>
                          <div className="text-xs text-muted-foreground">
                            {order.user.email}
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="font-medium">
                      {order.event.name}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Tag className="h-3 w-3 text-muted-foreground" />
                        <span>{order.ticketType.name}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary" className="font-semibold">
                        {order.quantity}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="font-semibold text-primary">
                        {formatCurrency(order.total)}
                      </div>
                    </TableCell>
                    <TableCell>{getStatusBadge(order.status)}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <CreditCard className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm">{order.paymentMethod}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2 text-sm">
                        <Calendar className="h-4 w-4 text-muted-foreground" />
                        <span>
                          {format(new Date(order.createdAt), "MMM dd, yyyy")}
                        </span>
                      </div>
                    </TableCell>
                    <TableCell className="text-right">
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleView(order.id)}
                        title="View Details"
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
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
          Page {page + 1} of {totalPages || 1} ({totalElements} total orders)
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
              <ShoppingCart className="h-5 w-5" />
              Order Details
            </DialogTitle>
            <DialogDescription>{selectedOrder?.event.name}</DialogDescription>
          </DialogHeader>
          {selectedOrder && (
            <div className="space-y-6">
              {/* Order Summary */}
              <div className="bg-muted/50 p-4 rounded-lg border">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Order ID
                    </Label>
                    <p className="font-mono text-sm font-semibold">
                      {selectedOrder.id}
                    </p>
                  </div>
                  <div>{getStatusBadge(selectedOrder.status)}</div>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Total Amount
                    </Label>
                    <p className="text-lg font-bold text-primary">
                      {formatCurrency(selectedOrder.total)}
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Quantity
                    </Label>
                    <p className="text-lg font-semibold flex items-center gap-1">
                      <Package className="h-5 w-5 text-muted-foreground" />
                      {selectedOrder.quantity} tickets
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Payment Method
                    </Label>
                    <p className="text-lg font-semibold flex items-center gap-1">
                      <CreditCard className="h-5 w-5 text-muted-foreground" />
                      {selectedOrder.paymentMethod}
                    </p>
                  </div>
                </div>
              </div>

              {/* User Information */}
              <div className="border rounded-lg p-4">
                <h3 className="font-semibold mb-4 flex items-center gap-2">
                  <User className="h-4 w-4" />
                  User Information
                </h3>
                <div className="flex items-start gap-4">
                  <Avatar className="h-12 w-12">
                    <AvatarImage
                      src={`https://api.dicebear.com/7.x/initials/svg?seed=${
                        selectedOrder.user.fullName ||
                        selectedOrder.user.username
                      }`}
                      alt="Avatar"
                    />
                    <AvatarFallback className="bg-primary text-primary-foreground">
                      {(
                        selectedOrder.user.fullName ||
                        selectedOrder.user.username
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
                        {selectedOrder.user.fullName ||
                          selectedOrder.user.username}
                      </p>
                    </div>
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Email
                      </Label>
                      <p className="break-words">{selectedOrder.user.email}</p>
                    </div>
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Phone
                      </Label>
                      <p>{selectedOrder.user.phone || "-"}</p>
                    </div>
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        User ID
                      </Label>
                      <p className="font-mono text-xs break-all">
                        {selectedOrder.user.id}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

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
                      {selectedOrder.event.name}
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Event ID
                    </Label>
                    <p className="font-mono text-xs break-all">
                      {selectedOrder.event.id}
                    </p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Venue
                    </Label>
                    <p>{selectedOrder.event.venueName || "-"}</p>
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Start Date
                    </Label>
                    <p className="flex items-center gap-1">
                      <Calendar className="h-3 w-3 text-muted-foreground" />
                      {format(new Date(selectedOrder.event.startDate), "PPpp")}
                    </p>
                  </div>
                </div>
              </div>

              {/* Order Details */}
              <div className="border rounded-lg p-4">
                <h3 className="font-semibold mb-4 flex items-center gap-2">
                  <Package className="h-4 w-4" />
                  Order Details
                </h3>
                <div className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Ticket Type
                      </Label>
                      <div className="flex items-center gap-2">
                        <Tag className="h-4 w-4 text-muted-foreground" />
                        <p className="font-medium break-words">
                          {selectedOrder.ticketType.name}
                        </p>
                      </div>
                    </div>
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Quantity
                      </Label>
                      <p className="font-semibold">{selectedOrder.quantity}</p>
                    </div>
                  </div>

                  <div className="border-t pt-4 space-y-2">
                    <div className="flex justify-between items-center">
                      <Label className="text-sm">Subtotal</Label>
                      <p className="font-medium">
                        {formatCurrency(selectedOrder.subtotal)}
                      </p>
                    </div>
                    {selectedOrder.discount > 0 && (
                      <div className="flex justify-between items-center text-green-600">
                        <Label className="text-sm flex items-center gap-1">
                          <Tag className="h-3 w-3" />
                          Discount
                          {selectedOrder.voucherCode && (
                            <span className="text-xs text-muted-foreground">
                              ({selectedOrder.voucherCode})
                            </span>
                          )}
                        </Label>
                        <p className="font-medium">
                          -{formatCurrency(selectedOrder.discount)}
                        </p>
                      </div>
                    )}
                    <div className="flex justify-between items-center pt-2 border-t">
                      <Label className="text-base font-semibold">Total</Label>
                      <p className="text-lg font-bold text-primary">
                        {formatCurrency(selectedOrder.total)}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Timestamps */}
              <div className="border rounded-lg p-4">
                <h3 className="font-semibold mb-4 flex items-center gap-2">
                  <Clock className="h-4 w-4" />
                  Timestamps
                </h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <Label className="text-xs text-muted-foreground">
                      Created At
                    </Label>
                    <p className="flex items-center gap-1">
                      <Calendar className="h-3 w-3 text-muted-foreground" />
                      {format(new Date(selectedOrder.createdAt), "PPpp")}
                    </p>
                  </div>
                  {selectedOrder.expiresAt && (
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Expires At
                      </Label>
                      <p className="flex items-center gap-1">
                        <Clock className="h-3 w-3 text-muted-foreground" />
                        {format(new Date(selectedOrder.expiresAt), "PPpp")}
                      </p>
                    </div>
                  )}
                  {selectedOrder.completedAt && (
                    <div>
                      <Label className="text-xs text-muted-foreground">
                        Completed At
                      </Label>
                      <p className="flex items-center gap-1">
                        <CheckCircle2 className="h-3 w-3 text-green-600" />
                        {format(new Date(selectedOrder.completedAt), "PPpp")}
                      </p>
                    </div>
                  )}
                </div>
                {selectedOrder.paymentUrl && (
                  <div className="mt-4 pt-4 border-t">
                    <Label className="text-xs text-muted-foreground">
                      Payment URL
                    </Label>
                    <p className="break-all text-sm font-mono bg-muted p-2 rounded mt-1">
                      {selectedOrder.paymentUrl}
                    </p>
                  </div>
                )}
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setViewDialogOpen(false)}>
              Close
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
