import { useEffect, useState } from "react";
import { permissionApi, PermissionResponse } from "@/lib/api";
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
import { Plus, Trash2 } from "lucide-react";
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
import { Textarea } from "@/components/ui/textarea";
import { showError, showSuccess } from "@/lib/errorHandler";
import { ConfirmDialog } from "@/components/ConfirmDialog";

export default function Permissions() {
  const { canManagePermissions } = usePermissions();
  const [permissions, setPermissions] = useState<PermissionResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [permissionToDelete, setPermissionToDelete] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    description: "",
  });

  useEffect(() => {
    loadPermissions();
  }, []);

  const loadPermissions = async () => {
    try {
      const response = await permissionApi.getPermissions();
      setPermissions(response.result);
    } catch (error) {
      console.error("Failed to load permissions:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = () => {
    setFormData({
      name: "",
      description: "",
    });
    setDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await permissionApi.createPermission({
        name: formData.name,
        description: formData.description || undefined,
      });
      setDialogOpen(false);
      showSuccess("Permission created successfully");
      loadPermissions();
    } catch (error: any) {
      console.error("Failed to create permission:", error);
      showError(error);
    }
  };

  const handleDelete = (permissionName: string) => {
    setPermissionToDelete(permissionName);
    setConfirmDialogOpen(true);
  };

  const confirmDelete = async () => {
    if (!permissionToDelete) return;
    try {
      await permissionApi.deletePermission(permissionToDelete);
      showSuccess("Permission deleted successfully");
      loadPermissions();
      setPermissionToDelete(null);
    } catch (error) {
      console.error("Failed to delete permission:", error);
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
          <h1 className="text-3xl font-bold">Permissions</h1>
          <p className="text-muted-foreground">Manage system permissions</p>
        </div>
        {canManagePermissions() && (
          <Button onClick={handleCreate}>
            <Plus className="mr-2 h-4 w-4" />
            Add Permission
          </Button>
        )}
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Description</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {permissions.map((permission) => (
                <TableRow key={permission.name}>
                  <TableCell className="font-medium">
                    {permission.name}
                  </TableCell>
                  <TableCell>{permission.description || "-"}</TableCell>
                  <TableCell className="text-right">
                    {canManagePermissions() && (
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleDelete(permission.name)}
                      >
                        <Trash2 className="h-4 w-4 text-destructive" />
                      </Button>
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
            <DialogTitle>Create Permission</DialogTitle>
            <DialogDescription>
              Add a new permission to the system
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit}>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="name">Permission Name *</Label>
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
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) =>
                    setFormData({ ...formData, description: e.target.value })
                  }
                  rows={3}
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
              <Button type="submit">Create</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={confirmDialogOpen}
        onOpenChange={setConfirmDialogOpen}
        title="Delete Permission"
        description={`Are you sure you want to delete permission "${permissionToDelete}"? This action cannot be undone.`}
        confirmText="Delete"
        cancelText="Cancel"
        onConfirm={confirmDelete}
        variant="destructive"
      />
    </div>
  );
}
