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
import { showError, showWarning } from "@/lib/errorHandler";
import { Tag, Percent, Calendar, CheckCircle2, XCircle, TrendingUp } from "lucide-react";

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
      showWarning("Please fill in all required fields");
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
      showError(error);
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
          <TrendingUp className="mr-2 h-4 w-4" />
          Validate Voucher
        </Button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b pb-2">
        <Button
          variant={activeTab === "public" ? "default" : "ghost"}
          onClick={() => setActiveTab("public")}
          className="rounded-b-none"
        >
          <Tag className="mr-2 h-4 w-4" />
          Public Vouchers
        </Button>
        <Button
          variant={activeTab === "user" ? "default" : "ghost"}
          onClick={() => setActiveTab("user")}
          className="rounded-b-none"
        >
          <Tag className="mr-2 h-4 w-4" />
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
                <TableHead>Usage Limit</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {activeTab === "public"
                ? publicVouchers.map((voucher) => (
                    <TableRow key={voucher.id}>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Tag className="h-4 w-4 text-muted-foreground" />
                          <span className="font-mono font-semibold text-primary">
                            {voucher.code}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="font-medium">
                        {voucher.title}
                        {voucher.description && (
                          <p className="text-sm text-muted-foreground mt-1">
                            {voucher.description}
                          </p>
                        )}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          {voucher.discountType === "FIXED_AMOUNT" ? (
                            <span className="px-2 py-1 text-xs font-semibold bg-blue-100 text-blue-800 rounded flex items-center gap-1">
                              <span>{voucher.discountValue}</span>
                              <span className="text-[10px]">{voucher.currency || "VND"}</span>
                            </span>
                          ) : (
                            <span className="px-2 py-1 text-xs font-semibold bg-purple-100 text-purple-800 rounded flex items-center gap-1">
                              <Percent className="h-3 w-3" />
                              <span>{voucher.discountValue}%</span>
                            </span>
                          )}
                          {voucher.maxDiscount &&
                            voucher.discountType === "PERCENTAGE" && (
                              <span className="text-xs text-muted-foreground">
                                (max {voucher.maxDiscount})
                              </span>
                            )}
                        </div>
                        {voucher.minOrderAmount && (
                          <p className="text-xs text-muted-foreground mt-1">
                            Min: {voucher.minOrderAmount}
                          </p>
                        )}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2 text-sm">
                          <Calendar className="h-4 w-4 text-muted-foreground" />
                          <div>
                            <div>
                              {format(new Date(voucher.startDate), "MMM dd, yyyy")}
                            </div>
                            <div className="text-muted-foreground">
                              to {format(new Date(voucher.endDate), "MMM dd, yyyy")}
                            </div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <span className="px-2 py-1 text-xs font-semibold bg-muted text-muted-foreground rounded">
                            {voucher.usedCount || 0} / {voucher.usageLimit || "∞"}
                          </span>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))
                : userVouchers.map((uv) => (
                    <TableRow key={uv.id}>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Tag className="h-4 w-4 text-muted-foreground" />
                          <span className="font-mono font-semibold text-primary">
                            {uv.voucher.code}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="font-medium">
                        {uv.voucher.title}
                        {uv.voucher.description && (
                          <p className="text-sm text-muted-foreground mt-1">
                            {uv.voucher.description}
                          </p>
                        )}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          {uv.voucher.discountType === "FIXED_AMOUNT" ? (
                            <span className="px-2 py-1 text-xs font-semibold bg-blue-100 text-blue-800 rounded flex items-center gap-1">
                              <span>{uv.voucher.discountValue}</span>
                              <span className="text-[10px]">{uv.voucher.currency || "VND"}</span>
                            </span>
                          ) : (
                            <span className="px-2 py-1 text-xs font-semibold bg-purple-100 text-purple-800 rounded flex items-center gap-1">
                              <Percent className="h-3 w-3" />
                              <span>{uv.voucher.discountValue}%</span>
                            </span>
                          )}
                        </div>
                        {uv.voucher.minOrderAmount && (
                          <p className="text-xs text-muted-foreground mt-1">
                            Min: {uv.voucher.minOrderAmount}
                          </p>
                        )}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2 text-sm">
                          <Calendar className="h-4 w-4 text-muted-foreground" />
                          <div>
                            <div>
                              {format(new Date(uv.voucher.startDate), "MMM dd, yyyy")}
                            </div>
                            <div className="text-muted-foreground">
                              to {format(new Date(uv.voucher.endDate), "MMM dd, yyyy")}
                            </div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        {uv.isUsed ? (
                          <span className="px-2 py-1 text-xs font-semibold bg-red-100 text-red-800 rounded flex items-center gap-1 w-fit">
                            <XCircle className="h-3 w-3" />
                            Used
                          </span>
                        ) : (
                          <span className="px-2 py-1 text-xs font-semibold bg-green-100 text-green-800 rounded flex items-center gap-1 w-fit">
                            <CheckCircle2 className="h-3 w-3" />
                            Available
                          </span>
                        )}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <span className="px-2 py-1 text-xs font-semibold bg-muted text-muted-foreground rounded">
                            {uv.voucher.usedCount || 0} / {uv.voucher.usageLimit || "∞"}
                          </span>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Validate Dialog */}
      <Dialog open={validateDialogOpen} onOpenChange={setValidateDialogOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5" />
              Validate Voucher
            </DialogTitle>
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
                className={`p-4 rounded-lg border-2 ${
                  validationResult.isValid
                    ? "bg-green-50 border-green-300"
                    : "bg-red-50 border-red-300"
                }`}
              >
                <div className="flex items-center gap-2 mb-2">
                  {validationResult.isValid ? (
                    <CheckCircle2 className="h-5 w-5 text-green-600" />
                  ) : (
                    <XCircle className="h-5 w-5 text-red-600" />
                  )}
                  <p className="font-semibold text-lg">
                    {validationResult.isValid ? "Valid Voucher" : "Invalid Voucher"}
                  </p>
                </div>
                <p className="text-sm mb-3">{validationResult.message}</p>
                {validationResult.isValid && validationResult.voucher && (
                  <div className="mt-3 pt-3 border-t space-y-2">
                    <div className="grid grid-cols-2 gap-2 text-sm">
                      <div>
                        <span className="text-muted-foreground">Order Amount:</span>
                        <p className="font-semibold">{validationResult.orderAmount}</p>
                      </div>
                      <div>
                        <span className="text-muted-foreground">Discount:</span>
                        <p className="font-semibold text-green-600">
                          -{validationResult.discountAmount} (
                          {getDiscountTypeLabel(
                            validationResult.voucher.discountType
                          )}
                          )
                        </p>
                      </div>
                    </div>
                    <div className="pt-2 border-t">
                      <span className="text-muted-foreground text-sm">Final Amount:</span>
                      <p className="font-bold text-lg text-primary">
                        {validationResult.finalAmount}
                      </p>
                    </div>
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
