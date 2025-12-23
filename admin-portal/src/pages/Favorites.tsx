import { useEffect, useState } from "react";
import { favoriteApi, EventResponse } from "@/lib/api";
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
import { Heart, Trash2 } from "lucide-react";
import { format } from "date-fns";

export default function Favorites() {
  const { isAdmin } = usePermissions();
  const [favorites, setFavorites] = useState<EventResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);

  useEffect(() => {
    loadFavorites();
  }, [page]);

  const loadFavorites = async () => {
    try {
      setLoading(true);
      const response = await favoriteApi.getFavorites({
        page: page,
        size: 10,
      });
      setFavorites(response.result.content);
      setTotalPages(response.result.totalPages);
      setTotalElements(response.result.totalElements);
    } catch (error) {
      console.error("Failed to load favorites:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleRemoveFavorite = async (eventId: string) => {
    try {
      await favoriteApi.removeFavorite(eventId);
      loadFavorites();
    } catch (error) {
      console.error("Failed to remove favorite:", error);
      alert("Failed to remove favorite");
    }
  };

  if (loading && favorites.length === 0) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">
            {isAdmin() ? "Favorites" : "My Favorites"}
          </h1>
          <p className="text-muted-foreground">
            {isAdmin() ? "All favorite events" : "Your favorite events"} (
            {totalElements} total)
          </p>
        </div>
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Event Name</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>City</TableHead>
                <TableHead>Start Date</TableHead>
                <TableHead>Price Range</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {favorites.map((event) => (
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
                  <TableCell className="text-right">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => handleRemoveFavorite(event.id)}
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {favorites.length === 0 && !loading && (
        <div className="text-center py-12">
          <Heart className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
          <p className="text-muted-foreground">No favorite events yet</p>
        </div>
      )}

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
