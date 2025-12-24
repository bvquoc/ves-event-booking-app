import { useEffect, useState } from "react";
import { notificationApi, NotificationResponse } from "@/lib/api";
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
import { CheckCheck, Check } from "lucide-react";
import { format } from "date-fns";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import { showError, showSuccess } from "@/lib/errorHandler";

export default function Notifications() {
  const { isAdmin } = usePermissions();
  const [notifications, setNotifications] = useState<NotificationResponse[]>(
    []
  );
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [unreadOnly, setUnreadOnly] = useState(false);

  useEffect(() => {
    loadNotifications();
  }, [page, unreadOnly]);

  const loadNotifications = async () => {
    try {
      setLoading(true);
      const response = await notificationApi.getNotifications({
        unreadOnly,
        pageable: { page, size: 10 },
      });
      setNotifications(response.result.content);
      setTotalPages(response.result.totalPages);
      setTotalElements(response.result.totalElements);
    } catch (error) {
      console.error("Failed to load notifications:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleMarkAsRead = async (notificationId: string) => {
    try {
      await notificationApi.markAsRead(notificationId);
      loadNotifications();
    } catch (error) {
      console.error("Failed to mark notification as read:", error);
      showError(error);
    }
  };

  const handleMarkAllAsRead = async () => {
    try {
      await notificationApi.markAllAsRead();
      showSuccess("All notifications marked as read");
      loadNotifications();
    } catch (error) {
      console.error("Failed to mark all as read:", error);
      showError(error);
    }
  };

  const getTypeColor = (type: string) => {
    switch (type) {
      case "TICKET_PURCHASED":
        return "text-green-600 bg-green-50";
      case "EVENT_REMINDER":
        return "text-blue-600 bg-blue-50";
      case "EVENT_CANCELLED":
        return "text-red-600 bg-red-50";
      case "PROMOTION":
        return "text-purple-600 bg-purple-50";
      case "SYSTEM":
        return "text-gray-600 bg-gray-50";
      default:
        return "text-gray-600 bg-gray-50";
    }
  };

  if (loading && notifications.length === 0) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">
            {isAdmin() ? "Notifications" : "My Notifications"}
          </h1>
          <p className="text-muted-foreground">
            {isAdmin() ? "Manage all notifications" : "View your notifications"}{" "}
            ({totalElements} total)
          </p>
        </div>
        <Button onClick={handleMarkAllAsRead} variant="outline">
          <CheckCheck className="mr-2 h-4 w-4" />
          Mark All as Read
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex items-center space-x-2">
            <Checkbox
              id="unreadOnly"
              checked={unreadOnly}
              onCheckedChange={(checked: boolean) => {
                setUnreadOnly(checked);
                setPage(0);
              }}
            />
            <Label htmlFor="unreadOnly" className="cursor-pointer">
              Show unread only
            </Label>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Type</TableHead>
                <TableHead>Title</TableHead>
                <TableHead>Message</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {notifications.map((notification) => (
                <TableRow
                  key={notification.id}
                  className={notification.isRead ? "" : "bg-muted/50"}
                >
                  <TableCell>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${getTypeColor(
                        notification.type
                      )}`}
                    >
                      {notification.type.replace("_", " ")}
                    </span>
                  </TableCell>
                  <TableCell className="font-medium">
                    {notification.title}
                  </TableCell>
                  <TableCell className="max-w-md truncate">
                    {notification.message}
                  </TableCell>
                  <TableCell>
                    {notification.isRead ? (
                      <span className="text-sm text-muted-foreground">
                        Read
                      </span>
                    ) : (
                      <span className="text-sm font-semibold text-primary">
                        Unread
                      </span>
                    )}
                  </TableCell>
                  <TableCell>
                    {format(new Date(notification.createdAt), "MMM dd, yyyy")}
                  </TableCell>
                  <TableCell className="text-right">
                    {!notification.isRead && (
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleMarkAsRead(notification.id)}
                      >
                        <Check className="h-4 w-4" />
                      </Button>
                    )}
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
    </div>
  );
}
