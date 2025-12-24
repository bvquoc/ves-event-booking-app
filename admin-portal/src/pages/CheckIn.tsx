import { useState, useRef, useEffect } from "react";
import {
  adminTicketApi,
  CheckInResponse,
  AdminTicketResponse,
} from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  QrCode,
  CheckCircle2,
  XCircle,
  AlertCircle,
  LogOut,
  Camera,
  CameraOff,
} from "lucide-react";
import { format } from "date-fns";
import { useAuth } from "@/contexts/AuthContext";
import { useNavigate } from "react-router-dom";
import { Html5Qrcode } from "html5-qrcode";

export default function CheckIn() {
  const { logout } = useAuth();
  const navigate = useNavigate();
  const [qrCode, setQrCode] = useState("");
  const [loading, setLoading] = useState(false);
  const [ticket, setTicket] = useState<AdminTicketResponse | null>(null);
  const [checkInResult, setCheckInResult] = useState<CheckInResponse | null>(
    null
  );
  const [error, setError] = useState<string | null>(null);
  const [isScanning, setIsScanning] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const scannerRef = useRef<Html5Qrcode | null>(null);
  const scannerContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Auto-focus on input when component mounts (if not scanning)
    if (!isScanning) {
      inputRef.current?.focus();
    }
  }, [isScanning]);

  // Cleanup scanner on unmount
  useEffect(() => {
    return () => {
      if (scannerRef.current) {
        scannerRef.current
          .stop()
          .then(() => {
            scannerRef.current = null;
          })
          .catch((err) => {
            console.error("Error stopping scanner:", err);
          });
      }
    };
  }, []);

  const processQrCode = async (code: string) => {
    if (!code.trim()) {
      return;
    }

    try {
      setLoading(true);
      setError(null);
      setTicket(null);
      setCheckInResult(null);
      setQrCode(code.trim());

      const response = await adminTicketApi.getTicketByQrCode(code.trim());
      setTicket(response.result);

      // If ticket is active and not checked in, automatically check in
      if (response.result.status === "ACTIVE" && !response.result.checkedInAt) {
        // Small delay to show the ticket info first
        setTimeout(() => {
          handleCheckIn(code.trim());
        }, 500);
      }
    } catch (err: unknown) {
      console.error("Failed to lookup ticket:", err);
      const error = err as { response?: { data?: { message?: string } } };
      setError(error.response?.data?.message || "Ticket not found");
      setTicket(null);
    } finally {
      setLoading(false);
    }
  };

  const handleLookup = async () => {
    if (!qrCode.trim()) {
      setError("Please enter a QR code");
      return;
    }
    await processQrCode(qrCode.trim());
  };

  const handleCheckIn = async (code?: string) => {
    const codeToUse = code || qrCode;
    if (!codeToUse.trim()) {
      setError("Please enter a QR code");
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const response = await adminTicketApi.checkInTicket({
        qrCode: codeToUse.trim(),
      });
      setCheckInResult(response.result);
      setTicket(response.result.ticketDetails);

      // Stop scanning after successful check-in
      if (isScanning) {
        stopScanning();
      }
    } catch (err: unknown) {
      console.error("Failed to check in ticket:", err);
      const error = err as { response?: { data?: { message?: string } } };
      setError(error.response?.data?.message || "Failed to check in ticket");
      setCheckInResult(null);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setQrCode("");
    setTicket(null);
    setCheckInResult(null);
    setError(null);
    setCameraError(null);
    if (!isScanning) {
      inputRef.current?.focus();
    }
  };

  const startScanning = async () => {
    try {
      setCameraError(null);
      setIsScanning(true);
      setError(null);

      const scanner = new Html5Qrcode("qr-reader");
      scannerRef.current = scanner;

      await scanner.start(
        { facingMode: "environment" }, // Use back camera on mobile
        {
          fps: 10,
          qrbox: { width: 250, height: 250 },
          aspectRatio: 1.0,
        },
        (decodedText) => {
          // Successfully scanned QR code
          processQrCode(decodedText);
        },
        () => {
          // Ignore scanning errors (they're frequent during scanning)
        }
      );
    } catch (err: unknown) {
      console.error("Failed to start camera:", err);
      const error = err as { message?: string };
      setCameraError(
        error.message || "Failed to access camera. Please check permissions."
      );
      setIsScanning(false);
      scannerRef.current = null;
    }
  };

  const stopScanning = async () => {
    try {
      if (scannerRef.current) {
        await scannerRef.current.stop();
        await scannerRef.current.clear();
        scannerRef.current = null;
      }
      setIsScanning(false);
      setCameraError(null);
      inputRef.current?.focus();
    } catch (err) {
      console.error("Error stopping scanner:", err);
      setIsScanning(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      if (ticket && ticket.status === "ACTIVE") {
        handleCheckIn();
      } else {
        handleLookup();
      }
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

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl space-y-6">
        {/* Header */}
        <div className="text-center space-y-2">
          <div className="flex items-center justify-center gap-3">
            <QrCode className="h-10 w-10 text-indigo-600" />
            <h1 className="text-4xl font-bold text-gray-900">Event Check-In</h1>
          </div>
          <p className="text-gray-600">
            Scan or enter QR code to check in attendees
          </p>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              logout();
              navigate("/login");
            }}
            className="mt-2"
          >
            <LogOut className="h-4 w-4 mr-2" />
            Logout
          </Button>
        </div>

        {/* QR Code Input */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <span>Enter QR Code</span>
              {!isScanning ? (
                <Button
                  onClick={startScanning}
                  variant="outline"
                  size="sm"
                  disabled={loading}
                >
                  <Camera className="h-4 w-4 mr-2" />
                  Use Camera
                </Button>
              ) : (
                <Button
                  onClick={stopScanning}
                  variant="outline"
                  size="sm"
                  disabled={loading}
                >
                  <CameraOff className="h-4 w-4 mr-2" />
                  Stop Camera
                </Button>
              )}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {isScanning ? (
              <div className="space-y-4">
                <div
                  id="qr-reader"
                  ref={scannerContainerRef}
                  className="w-full rounded-lg overflow-hidden"
                ></div>
                {cameraError && (
                  <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded text-red-700">
                    <AlertCircle className="h-5 w-5" />
                    <span>{cameraError}</span>
                  </div>
                )}
                <Button
                  onClick={stopScanning}
                  variant="outline"
                  className="w-full"
                >
                  <CameraOff className="h-4 w-4 mr-2" />
                  Stop Camera
                </Button>
              </div>
            ) : (
              <div className="flex gap-2">
                <Input
                  ref={inputRef}
                  type="text"
                  placeholder="Enter or scan QR code..."
                  value={qrCode}
                  onChange={(e) => setQrCode(e.target.value)}
                  onKeyPress={handleKeyPress}
                  className="text-lg"
                  disabled={loading}
                  autoFocus
                />
                {!ticket ? (
                  <Button
                    onClick={handleLookup}
                    disabled={loading || !qrCode.trim()}
                  >
                    Lookup
                  </Button>
                ) : (
                  <Button onClick={handleReset} variant="outline">
                    Clear
                  </Button>
                )}
              </div>
            )}

            {error && (
              <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded text-red-700">
                <AlertCircle className="h-5 w-5" />
                <span>{error}</span>
              </div>
            )}

            {checkInResult && (
              <div
                className={`flex items-center gap-2 p-4 rounded ${
                  checkInResult.status === "USED"
                    ? "bg-green-50 border border-green-200"
                    : "bg-yellow-50 border border-yellow-200"
                }`}
              >
                {checkInResult.status === "USED" ? (
                  <CheckCircle2 className="h-6 w-6 text-green-600" />
                ) : (
                  <AlertCircle className="h-6 w-6 text-yellow-600" />
                )}
                <div>
                  <p className="font-semibold">{checkInResult.message}</p>
                  {checkInResult.checkedInAt && (
                    <p className="text-sm text-muted-foreground">
                      Checked in at:{" "}
                      {format(new Date(checkInResult.checkedInAt), "PPpp")}
                    </p>
                  )}
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Ticket Details */}
        {ticket && (
          <Card>
            <CardHeader>
              <CardTitle>Ticket Information</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-muted-foreground">Ticket ID</Label>
                  <p className="font-mono text-sm">
                    {ticket.id.substring(0, 8)}...
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Status</Label>
                  <p>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(
                        ticket.status
                      )}`}
                    >
                      {ticket.status}
                    </span>
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Event</Label>
                  <p className="font-medium">{ticket.event.name}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Venue</Label>
                  <p>{ticket.event.venueName || "-"}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Ticket Type</Label>
                  <p>{ticket.ticketType.name}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Seat</Label>
                  <p>
                    {ticket.seat
                      ? `${ticket.seat.section} - ${ticket.seat.row} - ${ticket.seat.seatNumber}`
                      : "General admission"}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Attendee</Label>
                  <p className="font-medium">
                    {ticket.user.fullName || ticket.user.username}
                  </p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Email</Label>
                  <p>{ticket.user.email}</p>
                </div>
                <div>
                  <Label className="text-muted-foreground">Purchase Date</Label>
                  <p>{format(new Date(ticket.purchaseDate), "PPp")}</p>
                </div>
                {ticket.checkedInAt && (
                  <div>
                    <Label className="text-muted-foreground">
                      Checked In At
                    </Label>
                    <p>{format(new Date(ticket.checkedInAt), "PPp")}</p>
                  </div>
                )}
              </div>

              {ticket.status === "ACTIVE" && !ticket.checkedInAt && (
                <div className="pt-4 border-t">
                  <Button
                    onClick={() => handleCheckIn()}
                    disabled={loading}
                    className="w-full"
                    size="lg"
                  >
                    <CheckCircle2 className="h-5 w-5 mr-2" />
                    Check In Ticket
                  </Button>
                </div>
              )}

              {ticket.status === "USED" && ticket.checkedInAt && (
                <div className="pt-4 border-t">
                  <div className="flex items-center gap-2 p-3 bg-green-50 border border-green-200 rounded">
                    <CheckCircle2 className="h-5 w-5 text-green-600" />
                    <div>
                      <p className="font-semibold text-green-900">
                        Already Checked In
                      </p>
                      <p className="text-sm text-green-700">
                        Checked in at:{" "}
                        {format(new Date(ticket.checkedInAt), "PPpp")}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {(ticket.status === "CANCELLED" ||
                ticket.status === "REFUNDED") && (
                <div className="pt-4 border-t">
                  <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded">
                    <XCircle className="h-5 w-5 text-red-600" />
                    <p className="font-semibold text-red-900">
                      Ticket is {ticket.status.toLowerCase()}
                    </p>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {/* Instructions */}
        {!ticket && (
          <Card className="bg-blue-50 border-blue-200">
            <CardContent className="pt-6">
              <div className="flex items-start gap-3">
                <AlertCircle className="h-5 w-5 text-blue-600 mt-0.5" />
                <div className="text-sm text-blue-800">
                  <p className="font-semibold mb-1">Instructions:</p>
                  <ul className="list-disc list-inside space-y-1">
                    <li>
                      Click "Use Camera" to scan QR codes with your device
                      camera
                    </li>
                    <li>Or enter the QR code manually in the input field</li>
                    <li>Click "Lookup" to view ticket details</li>
                    <li>
                      Click "Check In Ticket" to mark the attendee as checked in
                    </li>
                    <li>Press Enter to quickly lookup or check in</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
