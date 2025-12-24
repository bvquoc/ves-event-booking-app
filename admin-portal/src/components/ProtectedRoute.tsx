import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { usePermissions } from "@/hooks/usePermissions";

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, loading } = useAuth();
  const { isCheckInUser } = usePermissions();
  const location = useLocation();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-muted-foreground">Loading...</div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  // Redirect STAFF/ORGANIZER users to check-in page (unless already there)
  if (isCheckInUser() && location.pathname !== "/check-in") {
    return <Navigate to="/check-in" replace />;
  }

  // Redirect non-check-in users away from check-in page
  if (!isCheckInUser() && location.pathname === "/check-in") {
    return <Navigate to="/events" replace />;
  }

  return <>{children}</>;
}
