import { useEffect, useState } from "react";
import { voucherApi, VoucherResponse, UserVoucherResponse } from "@/lib/api";
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
import { eventApi, TicketTypeResponse } from "@/lib/api";
import { EventResponse } from "@/lib/api";
import { usePermissions } from "@/hooks/usePermissions";

export default function Vouchers() {
  const { isAdmin } = usePermissions();
  const [publicVouchers, setPublicVouchers] = useState<VoucherResponse[]>([]);
  const [userVouchers, setUserVouchers] = useState<UserVoucherResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"public" | "user">("public");
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [validateDialogOpen, setValidateDialogOpen] = useState(false);
  const [voucherCode, setVoucherCode] = useState("");
  const [selectedEventId, setSelectedEventId] = useState("");
  const [selectedTicketTypeId, setSelectedTicketTypeId] = useState("");
  const [quantity, setQuantity] = useState(1);
  const [events, setEvents] = useState<EventResponse[]>([]);
  const [ticketTypes, setTicketTypes] = useState<TicketTypeResponse[]>([]);
  const [validationResult, setValidationResult] = useState<any>(null);

  useEffect(() => {
    loadVouchers();
    loadEvents();
  }, [activeTab, statusFilter]);

  const loadVouchers = async () => {
    try {
      setLoading(true);
      if (activeTab === "public") {
        const response = await voucherApi.getPublicVouchers();
        setPublicVouchers(response.result);
      } else {
        const response = await voucherApi.getUserVouchers(
          statusFilter || undefined
        );
        setUserVouchers(response.result);
      }
    } catch (error) {
      console.error("Failed to load vouchers:", error);
    } finally {
      setLoading(false);
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

  const handleValidate = async () => {
    if (!voucherCode || !selectedEventId || !selectedTicketTypeId) {
      alert("Please fill in all required fields");
      return;
    }
    try {
      const response = await voucherApi.validateVoucher({
        voucherCode,
        eventId: selectedEventId,
        ticketTypeId: selectedTicketTypeId,
        quantity,
      });
      setValidationResult(response.result);
    } catch (error: any) {
      console.error("Failed to validate voucher:", error);
      alert(error.response?.data?.message || "Failed to validate voucher");
    }
  };

  const getDiscountTypeLabel = (type: string) => {
    return type === "FIXED_AMOUNT" ? "Fixed Amount" : "Percentage";
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">
            {isAdmin() ? "Vouchers" : "My Vouchers"}
          </h1>
          <p className="text-muted-foreground">
            {isAdmin() ? "Manage all vouchers" : "View and validate vouchers"}
          </p>
        </div>
        <Button onClick={() => setValidateDialogOpen(true)}>
          Validate Voucher
        </Button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b">
        <Button
          variant={activeTab === "public" ? "default" : "ghost"}
          onClick={() => setActiveTab("public")}
        >
          Public Vouchers
        </Button>
        <Button
          variant={activeTab === "user" ? "default" : "ghost"}
          onClick={() => setActiveTab("user")}
        >
          My Vouchers
        </Button>
      </div>

      {/* Filters for user vouchers */}
      {activeTab === "user" && (
        <Card>
          <CardContent className="p-4">
            <Select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="">All Statuses</option>
              <option value="USED">Used</option>
              <option value="AVAILABLE">Available</option>
            </Select>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Code</TableHead>
                <TableHead>Title</TableHead>
                <TableHead>Discount</TableHead>
                <TableHead>Valid Period</TableHead>
                {activeTab === "user" && <TableHead>Status</TableHead>}
                <TableHead>Usage</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {activeTab === "public"
                ? publicVouchers.map((voucher) => (
                    <TableRow key={voucher.id}>
                      <TableCell className="font-mono font-medium">
                        {voucher.code}
                      </TableCell>
                      <TableCell>{voucher.title}</TableCell>
                      <TableCell>
                        {voucher.discountType === "FIXED_AMOUNT"
                          ? `${voucher.discountValue}`
                          : `${voucher.discountValue}%`}
                        {voucher.maxDiscount &&
                          voucher.discountType === "PERCENTAGE" &&
                          ` (max ${voucher.maxDiscount})`}
                      </TableCell>
                      <TableCell>
                        {format(new Date(voucher.startDate), "MMM dd")} -{" "}
                        {format(new Date(voucher.endDate), "MMM dd, yyyy")}
                      </TableCell>
                      <TableCell>
                        {voucher.usedCount || 0} / {voucher.usageLimit || "∞"}
                      </TableCell>
                    </TableRow>
                  ))
                : userVouchers.map((uv) => (
                    <TableRow key={uv.id}>
                      <TableCell className="font-mono font-medium">
                        {uv.voucher.code}
                      </TableCell>
                      <TableCell>{uv.voucher.title}</TableCell>
                      <TableCell>
                        {uv.voucher.discountType === "FIXED_AMOUNT"
                          ? `${uv.voucher.discountValue}`
                          : `${uv.voucher.discountValue}%`}
                      </TableCell>
                      <TableCell>
                        {format(new Date(uv.voucher.startDate), "MMM dd")} -{" "}
                        {format(new Date(uv.voucher.endDate), "MMM dd, yyyy")}
                      </TableCell>
                      <TableCell>
                        {uv.isUsed ? (
                          <span className="text-red-600">Used</span>
                        ) : (
                          <span className="text-green-600">Available</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {uv.voucher.usedCount || 0} /{" "}
                        {uv.voucher.usageLimit || "∞"}
                      </TableCell>
                    </TableRow>
                  ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Validate Dialog */}
      <Dialog open={validateDialogOpen} onOpenChange={setValidateDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Validate Voucher</DialogTitle>
            <DialogDescription>
              Check if a voucher is valid for a specific purchase
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="voucherCode">Voucher Code *</Label>
              <Input
                id="voucherCode"
                value={voucherCode}
                onChange={(e) => setVoucherCode(e.target.value.toUpperCase())}
                placeholder="Enter voucher code"
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="eventId">Event *</Label>
              <Select
                id="eventId"
                value={selectedEventId}
                onChange={async (e) => {
                  setSelectedEventId(e.target.value);
                  setSelectedTicketTypeId("");
                  if (e.target.value) {
                    try {
                      const response = await eventApi.getEventTickets(
                        e.target.value
                      );
                      setTicketTypes(response.result);
                    } catch (error) {
                      console.error("Failed to load ticket types:", error);
                    }
                  } else {
                    setTicketTypes([]);
                  }
                }}
                required
              >
                <option value="">Select an event</option>
                {events.map((event) => (
                  <option key={event.id} value={event.id}>
                    {event.name}
                  </option>
                ))}
              </Select>
            </div>
            {selectedEventId && ticketTypes.length > 0 && (
              <div className="space-y-2">
                <Label htmlFor="ticketTypeId">Ticket Type *</Label>
                <Select
                  id="ticketTypeId"
                  value={selectedTicketTypeId}
                  onChange={(e) => setSelectedTicketTypeId(e.target.value)}
                  required
                >
                  <option value="">Select a ticket type</option>
                  {ticketTypes.map((tt) => (
                    <option key={tt.id} value={tt.id}>
                      {tt.name} - {tt.price} {tt.currency}
                    </option>
                  ))}
                </Select>
              </div>
            )}
            <div className="space-y-2">
              <Label htmlFor="quantity">Quantity *</Label>
              <Input
                id="quantity"
                type="number"
                min="1"
                value={quantity}
                onChange={(e) => setQuantity(parseInt(e.target.value) || 1)}
                required
              />
            </div>
            {validationResult && (
              <div
                className={`p-4 rounded ${
                  validationResult.isValid
                    ? "bg-green-50 border border-green-200"
                    : "bg-red-50 border border-red-200"
                }`}
              >
                <p className="font-semibold">
                  {validationResult.isValid ? "Valid" : "Invalid"}
                </p>
                <p className="text-sm">{validationResult.message}</p>
                {validationResult.isValid && validationResult.voucher && (
                  <div className="mt-2 space-y-1 text-sm">
                    <p>
                      Discount: {validationResult.discountAmount} (
                      {getDiscountTypeLabel(
                        validationResult.voucher.discountType
                      )}
                      )
                    </p>
                    <p>Order Amount: {validationResult.orderAmount}</p>
                    <p className="font-semibold">
                      Final Amount: {validationResult.finalAmount}
                    </p>
                  </div>
                )}
              </div>
            )}
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setValidateDialogOpen(false);
                setValidationResult(null);
              }}
            >
              Close
            </Button>
            <Button onClick={handleValidate}>Validate</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
