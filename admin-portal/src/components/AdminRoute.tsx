import { Navigate } from "react-router-dom";
import { usePermissions } from "@/hooks/usePermissions";
import { useAuth } from "@/contexts/AuthContext";

export function AdminRoute({ children }: { children: React.ReactNode }) {
  const { isAdmin } = usePermissions();
  const { loading } = useAuth();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-muted-foreground">Loading...</div>
      </div>
    );
  }

  if (!isAdmin()) {
    return <Navigate to="/events" replace />;
  }

  return <>{children}</>;
}

