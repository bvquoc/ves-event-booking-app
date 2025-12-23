import { useAuth } from "@/contexts/AuthContext";

export function usePermissions() {
  const { user } = useAuth();

  const hasRole = (roleName: string): boolean => {
    if (!user) return false;
    return user.roles.some((role) => role.name === roleName);
  };

  const hasAnyRole = (roleNames: string[]): boolean => {
    if (!user) return false;
    return user.roles.some((role) => roleNames.includes(role.name));
  };

  const isAdmin = (): boolean => {
    return hasRole("ADMIN") || hasRole("ROLE_ADMIN");
  };

  const canManageUsers = (): boolean => {
    return isAdmin();
  };

  const canManageEvents = (): boolean => {
    return isAdmin() || hasRole("EVENT_MANAGER");
  };

  const canManageRoles = (): boolean => {
    return isAdmin();
  };

  const canManagePermissions = (): boolean => {
    return isAdmin();
  };

  const canManageCities = (): boolean => {
    return isAdmin();
  };

  const canManageVenues = (): boolean => {
    return isAdmin();
  };

  return {
    hasRole,
    hasAnyRole,
    isAdmin,
    canManageUsers,
    canManageEvents,
    canManageRoles,
    canManagePermissions,
    canManageCities,
    canManageVenues,
    user,
  };
}
