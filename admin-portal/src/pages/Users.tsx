import { useEffect, useState } from "react";
import { userApi, roleApi, UserResponse, RoleResponse } from "@/lib/api";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { usePermissions } from "@/hooks/usePermissions";
import { showError, showSuccess } from "@/lib/errorHandler";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Plus, Edit, Trash2, User } from "lucide-react";
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
import { Checkbox } from "@/components/ui/checkbox";

export default function Users() {
  const { canManageUsers } = usePermissions();
  const [users, setUsers] = useState<UserResponse[]>([]);
  const [roles, setRoles] = useState<RoleResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState<string | null>(null);
  const [editingUser, setEditingUser] = useState<UserResponse | null>(null);
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    email: "",
    phone: "",
    firstName: "",
    lastName: "",
    dob: "",
    selectedRoles: [] as string[],
  });

  useEffect(() => {
    loadUsers();
    loadRoles();
  }, []);

  const loadUsers = async () => {
    try {
      const response = await userApi.getUsers();
      setUsers(response.result);
    } catch (error) {
      console.error("Failed to load users:", error);
    } finally {
      setLoading(false);
    }
  };

  const loadRoles = async () => {
    try {
      const response = await roleApi.getRoles();
      setRoles(response.result);
    } catch (error) {
      console.error("Failed to load roles:", error);
    }
  };

  const handleCreate = () => {
    setEditingUser(null);
    setFormData({
      username: "",
      password: "",
      email: "",
      phone: "",
      firstName: "",
      lastName: "",
      dob: "",
      selectedRoles: [],
    });
    setDialogOpen(true);
  };

  const handleEdit = (user: UserResponse) => {
    setEditingUser(user);
    setFormData({
      username: user.username,
      password: "",
      email: user.email || "",
      phone: user.phone || "",
      firstName: user.firstName || "",
      lastName: user.lastName || "",
      dob: user.dob || "",
      selectedRoles: user.roles.map((r) => r.name),
    });
    setDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingUser) {
        await userApi.updateUser(editingUser.id, {
          email: formData.email,
          phone: formData.phone,
          firstName: formData.firstName,
          lastName: formData.lastName,
          dob: formData.dob || undefined,
          password: formData.password || undefined,
          roles: formData.selectedRoles,
        });
      } else {
        await userApi.createUser({
          username: formData.username,
          password: formData.password,
          email: formData.email,
          phone: formData.phone,
          firstName: formData.firstName || undefined,
          lastName: formData.lastName || undefined,
          dob: formData.dob || undefined,
        });
      }
      setDialogOpen(false);
      showSuccess(
        editingUser ? "User updated successfully" : "User created successfully"
      );
      loadUsers();
    } catch (error) {
      console.error("Failed to save user:", error);
      showError(error);
    }
  };

  const handleDelete = (userId: string) => {
    setUserToDelete(userId);
    setConfirmDialogOpen(true);
  };

  const confirmDelete = async () => {
    if (!userToDelete) return;
    try {
      await userApi.deleteUser(userToDelete);
      showSuccess("User deleted successfully");
      loadUsers();
      setUserToDelete(null);
    } catch (error) {
      console.error("Failed to delete user:", error);
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
          <h1 className="text-3xl font-bold">Users</h1>
          <p className="text-muted-foreground">Manage system users</p>
        </div>
        {canManageUsers() && (
          <Button onClick={handleCreate}>
            <Plus className="mr-2 h-4 w-4" />
            Add User
          </Button>
        )}
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Phone</TableHead>
                <TableHead>First Name</TableHead>
                <TableHead>Last Name</TableHead>
                <TableHead>Date of Birth</TableHead>
                <TableHead>Roles</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {users.map((user) => {
                const getInitials = (
                  firstName?: string,
                  lastName?: string,
                  username?: string
                ) => {
                  if (firstName && lastName) {
                    return `${firstName[0]}${lastName[0]}`.toUpperCase();
                  }
                  if (firstName) {
                    return firstName[0].toUpperCase();
                  }
                  if (username) {
                    return username.substring(0, 2).toUpperCase();
                  }
                  return "U";
                };

                const initials = getInitials(
                  user.firstName,
                  user.lastName,
                  user.username
                );
                const displayName =
                  user.firstName && user.lastName
                    ? `${user.firstName} ${user.lastName}`
                    : user.firstName || user.lastName || user.username;

                return (
                  <TableRow key={user.id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                          {user.firstName || user.lastName ? (
                            <span className="text-sm font-semibold text-primary">
                              {initials}
                            </span>
                          ) : (
                            <User className="h-5 w-5 text-primary" />
                          )}
                        </div>
                        <div>
                          <div className="font-medium">{displayName}</div>
                          <div className="text-sm text-muted-foreground">
                            {user.username}
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{user.email}</TableCell>
                    <TableCell>{user.phone}</TableCell>
                    <TableCell>{user.firstName || "-"}</TableCell>
                    <TableCell>{user.lastName || "-"}</TableCell>
                    <TableCell>{user.dob || "-"}</TableCell>
                    <TableCell>
                      <div className="flex flex-wrap gap-1">
                        {user.roles && user.roles.length > 0 ? (
                          user.roles.map((role) => (
                            <span
                              key={role.name}
                              className="px-2 py-0.5 text-xs font-semibold bg-primary/10 text-primary rounded"
                            >
                              {role.name}
                            </span>
                          ))
                        ) : (
                          <span className="text-muted-foreground text-sm">
                            -
                          </span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell className="text-right">
                      {canManageUsers() && (
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEdit(user)}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(user.id)}
                          >
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        </div>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-6xl">
          <DialogHeader>
            <DialogTitle>
              {editingUser ? "Edit User" : "Create User"}
            </DialogTitle>
            <DialogDescription>
              {editingUser
                ? "Update user information"
                : "Add a new user to the system"}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit}>
            <div className="space-y-4 py-4">
              <div className="grid grid-cols-2 gap-4">
                {!editingUser && (
                  <div className="space-y-2">
                    <Label htmlFor="username">Username *</Label>
                    <Input
                      id="username"
                      value={formData.username}
                      onChange={(e) =>
                        setFormData({ ...formData, username: e.target.value })
                      }
                      required
                    />
                  </div>
                )}
                <div className="space-y-2">
                  <Label htmlFor="password">
                    {editingUser
                      ? "New Password (leave empty to keep current)"
                      : "Password *"}
                  </Label>
                  <Input
                    id="password"
                    type="password"
                    value={formData.password}
                    onChange={(e) =>
                      setFormData({ ...formData, password: e.target.value })
                    }
                    required={!editingUser}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="email">Email *</Label>
                  <Input
                    id="email"
                    type="email"
                    value={formData.email}
                    onChange={(e) =>
                      setFormData({ ...formData, email: e.target.value })
                    }
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone *</Label>
                  <Input
                    id="phone"
                    type="tel"
                    value={formData.phone}
                    onChange={(e) =>
                      setFormData({ ...formData, phone: e.target.value })
                    }
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="firstName">First Name</Label>
                  <Input
                    id="firstName"
                    value={formData.firstName}
                    onChange={(e) =>
                      setFormData({ ...formData, firstName: e.target.value })
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="lastName">Last Name</Label>
                  <Input
                    id="lastName"
                    value={formData.lastName}
                    onChange={(e) =>
                      setFormData({ ...formData, lastName: e.target.value })
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="dob">Date of Birth</Label>
                  <Input
                    id="dob"
                    type="date"
                    value={formData.dob}
                    onChange={(e) =>
                      setFormData({ ...formData, dob: e.target.value })
                    }
                  />
                </div>
              </div>
              {editingUser && (
                <div className="space-y-2">
                  <Label>Roles</Label>
                  <div className="space-y-2 border rounded-md p-3 max-h-40 overflow-y-auto">
                    {roles.map((role) => (
                      <div
                        key={role.name}
                        className="flex items-center space-x-2"
                      >
                        <Checkbox
                          id={`role-${role.name}`}
                          checked={formData.selectedRoles.includes(role.name)}
                          onCheckedChange={(checked: boolean) => {
                            if (checked) {
                              setFormData((prev) => ({
                                ...prev,
                                selectedRoles: [
                                  ...prev.selectedRoles,
                                  role.name,
                                ],
                              }));
                            } else {
                              setFormData((prev) => ({
                                ...prev,
                                selectedRoles: prev.selectedRoles.filter(
                                  (r) => r !== role.name
                                ),
                              }));
                            }
                          }}
                        />
                        <Label
                          htmlFor={`role-${role.name}`}
                          className="text-sm font-normal cursor-pointer"
                        >
                          {role.name}
                        </Label>
                      </div>
                    ))}
                  </div>
                </div>
              )}
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
        title="Delete User"
        description="Are you sure you want to delete this user? This action cannot be undone."
        confirmText="Delete"
        cancelText="Cancel"
        onConfirm={confirmDelete}
        variant="destructive"
      />
    </div>
  );
}
