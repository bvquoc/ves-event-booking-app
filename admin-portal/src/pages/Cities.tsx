import { useEffect, useState } from "react";
import { cityApi, CityResponse } from "@/lib/api";
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
import { Plus, Edit, Trash2 } from "lucide-react";
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
import { showError, showSuccess } from "@/lib/errorHandler";
import { ConfirmDialog } from "@/components/ConfirmDialog";

export default function Cities() {
  const { canManageCities } = usePermissions();
  const [cities, setCities] = useState<CityResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [cityToDelete, setCityToDelete] = useState<string | null>(null);
  const [editingCity, setEditingCity] = useState<CityResponse | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    slug: "",
  });

  useEffect(() => {
    loadCities();
  }, []);

  const loadCities = async () => {
    try {
      const response = await cityApi.getCities();
      setCities(response.result);
    } catch (error) {
      console.error("Failed to load cities:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = () => {
    setEditingCity(null);
    setFormData({ name: "", slug: "" });
    setDialogOpen(true);
  };

  const handleEdit = (city: CityResponse) => {
    setEditingCity(city);
    setFormData({
      name: city.name,
      slug: city.slug,
    });
    setDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingCity) {
        await cityApi.updateCity(editingCity.id, {
          name: formData.name,
          slug: formData.slug,
        });
      } else {
        await cityApi.createCity({
          name: formData.name,
          slug: formData.slug,
        });
      }
      setDialogOpen(false);
      showSuccess(
        editingCity ? "City updated successfully" : "City created successfully"
      );
      loadCities();
    } catch (error: any) {
      console.error("Failed to save city:", error);
      showError(error);
    }
  };

  const handleDelete = (cityId: string) => {
    setCityToDelete(cityId);
    setConfirmDialogOpen(true);
  };

  const confirmDelete = async () => {
    if (!cityToDelete) return;
    try {
      await cityApi.deleteCity(cityToDelete);
      showSuccess("City deleted successfully");
      loadCities();
      setCityToDelete(null);
    } catch (error) {
      console.error("Failed to delete city:", error);
      showError(error);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Cities</h1>
          <p className="text-muted-foreground">Manage cities</p>
        </div>
        {canManageCities() && (
          <Button onClick={handleCreate}>
            <Plus className="mr-2 h-4 w-4" />
            Add City
          </Button>
        )}
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Slug</TableHead>
                <TableHead>Event Count</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {cities.map((city) => (
                <TableRow key={city.id}>
                  <TableCell className="font-medium">{city.name}</TableCell>
                  <TableCell>{city.slug}</TableCell>
                  <TableCell>{city.eventCount || 0}</TableCell>
                  <TableCell className="text-right">
                    {canManageCities() && (
                      <div className="flex justify-end gap-2">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleEdit(city)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleDelete(city.id)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {editingCity ? "Edit City" : "Create City"}
            </DialogTitle>
            <DialogDescription>
              {editingCity
                ? "Update city information"
                : "Add a new city to the system"}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit}>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="name">City Name *</Label>
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
                  placeholder="e.g., ho-chi-minh"
                />
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

      <ConfirmDialog
        open={confirmDialogOpen}
        onOpenChange={setConfirmDialogOpen}
        title="Delete City"
        description="Are you sure you want to delete this city? This action cannot be undone."
        confirmText="Delete"
        cancelText="Cancel"
        onConfirm={confirmDelete}
        variant="destructive"
      />
    </div>
  );
}
