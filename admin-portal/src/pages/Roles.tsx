import { useEffect, useState } from "react";
import {
  roleApi,
  permissionApi,
  RoleResponse,
  PermissionResponse,
} from "@/lib/api";
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
import { Checkbox } from "@/components/ui/checkbox";
import { ConfirmDialog } from "@/components/ConfirmDialog";

export default function Roles() {
  const { canManageRoles } = usePermissions();
  const [roles, setRoles] = useState<RoleResponse[]>([]);
  const [permissions, setPermissions] = useState<PermissionResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [roleToDelete, setRoleToDelete] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    selectedPermissions: [] as string[],
  });

  useEffect(() => {
    loadRoles();
    loadPermissions();
  }, []);

  const loadRoles = async () => {
    try {
      const response = await roleApi.getRoles();
      setRoles(response.result);
    } catch (error) {
      console.error("Failed to load roles:", error);
    } finally {
      setLoading(false);
    }
  };

  const loadPermissions = async () => {
    try {
      const response = await permissionApi.getPermissions();
      setPermissions(response.result);
    } catch (error) {
      console.error("Failed to load permissions:", error);
    }
  };

  const handleCreate = () => {
    setFormData({
      name: "",
      description: "",
      selectedPermissions: [],
    });
    setDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await roleApi.createRole({
        name: formData.name,
        description: formData.description || undefined,
        permissions: formData.selectedPermissions,
      });
      setDialogOpen(false);
      showSuccess("Role created successfully");
      loadRoles();
    } catch (error: any) {
      console.error("Failed to create role:", error);
      showError(error);
    }
  };

  const handleDelete = (roleName: string) => {
    setRoleToDelete(roleName);
    setConfirmDialogOpen(true);
  };

  const confirmDelete = async () => {
    if (!roleToDelete) return;
    try {
      await roleApi.deleteRole(roleToDelete);
      showSuccess("Role deleted successfully");
      loadRoles();
      setRoleToDelete(null);
    } catch (error) {
      console.error("Failed to delete role:", error);
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
          <h1 className="text-3xl font-bold">Roles</h1>
          <p className="text-muted-foreground">Manage user roles</p>
        </div>
        {canManageRoles() && (
          <Button onClick={handleCreate}>
            <Plus className="mr-2 h-4 w-4" />
            Add Role
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
                <TableHead>Permissions</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {roles.map((role) => (
                <TableRow key={role.name}>
                  <TableCell className="font-medium">{role.name}</TableCell>
                  <TableCell>{role.description || "-"}</TableCell>
                  <TableCell>
                    <div className="flex flex-wrap gap-1">
                      {role.permissions.map((p) => (
                        <span
                          key={p.name}
                          className="px-2 py-1 text-xs bg-secondary rounded-md"
                        >
                          {p.name}
                        </span>
                      ))}
                      {role.permissions.length === 0 && (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </div>
                  </TableCell>
                  <TableCell className="text-right">
                    {canManageRoles() && (
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleDelete(role.name)}
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
            <DialogTitle>Create Role</DialogTitle>
            <DialogDescription>Add a new role to the system</DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit}>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="name">Role Name *</Label>
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
              <div className="space-y-2">
                <Label>Permissions</Label>
                <div className="space-y-2 border rounded-md p-3 max-h-60 overflow-y-auto">
                  {permissions.map((permission) => (
                    <div
                      key={permission.name}
                      className="flex items-center space-x-2"
                    >
                      <Checkbox
                        id={`perm-${permission.name}`}
                        checked={formData.selectedPermissions.includes(
                          permission.name
                        )}
                        onCheckedChange={(checked: boolean) => {
                          if (checked) {
                            setFormData((prev) => ({
                              ...prev,
                              selectedPermissions: [
                                ...prev.selectedPermissions,
                                permission.name,
                              ],
                            }));
                          } else {
                            setFormData((prev) => ({
                              ...prev,
                              selectedPermissions:
                                prev.selectedPermissions.filter(
                                  (p) => p !== permission.name
                                ),
                            }));
                          }
                        }}
                      />
                      <Label
                        htmlFor={`perm-${permission.name}`}
                        className="text-sm font-normal cursor-pointer flex-1"
                      >
                        <div>
                          <div className="font-medium">{permission.name}</div>
                          {permission.description && (
                            <div className="text-xs text-muted-foreground">
                              {permission.description}
                            </div>
                          )}
                        </div>
                      </Label>
                    </div>
                  ))}
                  {permissions.length === 0 && (
                    <p className="text-sm text-muted-foreground">
                      No permissions available
                    </p>
                  )}
                </div>
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
        title="Delete Role"
        description={`Are you sure you want to delete the role "${roleToDelete}"? This action cannot be undone.`}
        confirmText="Delete"
        cancelText="Cancel"
        onConfirm={confirmDelete}
        variant="destructive"
      />
    </div>
  );
}
