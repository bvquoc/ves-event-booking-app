import { Link, useLocation, Outlet } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { usePermissions } from "@/hooks/usePermissions";
import { Button } from "@/components/ui/button";
import {
  Users,
  Calendar,
  Shield,
  Key,
  MapPin,
  Building2,
  LogOut,
  Menu,
  Ticket,
  Bell,
  Tag,
  Heart,
  AlertCircle,
  ShoppingCart,
} from "lucide-react";
import { useState } from "react";

const navigation = [
  { name: "Users", href: "/users", icon: Users, adminOnly: true },
  {
    name: "Events",
    href: "/events",
    icon: Calendar,
    adminOnly: false,
    getLabel: (_isAdmin: boolean) => "Events",
  },
  {
    name: "Tickets",
    href: "/tickets",
    icon: Ticket,
    adminOnly: false,
    getLabel: (isAdmin: boolean) => (isAdmin ? "Tickets" : "My Tickets"),
  },
  { name: "Orders", href: "/orders", icon: ShoppingCart, adminOnly: true },
  {
    name: "Notifications",
    href: "/notifications",
    icon: Bell,
    adminOnly: false,
    getLabel: (isAdmin: boolean) =>
      isAdmin ? "Notifications" : "My Notifications",
  },
  {
    name: "Vouchers",
    href: "/vouchers",
    icon: Tag,
    adminOnly: false,
    getLabel: (isAdmin: boolean) => (isAdmin ? "Vouchers" : "My Vouchers"),
  },
  {
    name: "Favorites",
    href: "/favorites",
    icon: Heart,
    adminOnly: false,
    getLabel: (isAdmin: boolean) => (isAdmin ? "Favorites" : "My Favorites"),
  },
  { name: "Roles", href: "/roles", icon: Shield, adminOnly: true },
  { name: "Permissions", href: "/permissions", icon: Key, adminOnly: true },
  { name: "Cities", href: "/cities", icon: Building2, adminOnly: true },
  { name: "Venues", href: "/venues", icon: MapPin, adminOnly: true },
  {
    name: "Error Codes",
    href: "/error-codes",
    icon: AlertCircle,
    adminOnly: true,
  },
];

export default function Layout() {
  const location = useLocation();
  const { user, logout } = useAuth();
  const { isAdmin } = usePermissions();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-background">
      {/* Mobile sidebar */}
      <div
        className={`fixed inset-0 z-40 lg:hidden ${
          sidebarOpen ? "" : "hidden"
        }`}
      >
        <div
          className="fixed inset-0 bg-black/50"
          onClick={() => setSidebarOpen(false)}
        />
        <div className="fixed inset-y-0 left-0 w-64 bg-card border-r">
          <SidebarContent
            location={location}
            onNavigate={() => setSidebarOpen(false)}
            isAdminUser={isAdmin()}
          />
        </div>
      </div>

      <div className="flex">
        {/* Desktop sidebar */}
        <aside className="hidden lg:flex lg:w-64 lg:flex-col lg:fixed lg:inset-y-0 lg:z-30">
          <div className="flex flex-col flex-grow bg-card border-r pt-5 pb-4 overflow-y-auto">
            <SidebarContent location={location} isAdminUser={isAdmin()} />
          </div>
        </aside>

        {/* Main content */}
        <div className="flex flex-col flex-1 lg:pl-64 min-w-0">
          {/* Top bar */}
          <header className="sticky top-0 z-20 flex-shrink-0 flex h-16 bg-card border-b">
            <div className="flex-1 px-4 flex justify-between items-center min-w-0">
              <Button
                variant="ghost"
                size="icon"
                className="lg:hidden"
                onClick={() => setSidebarOpen(true)}
              >
                <Menu className="h-6 w-6" />
              </Button>
              <div className="flex-1" />
              <div className="flex items-center gap-4">
                <span className="text-sm text-muted-foreground">
                  {user?.firstName} {user?.lastName}
                </span>
                <Button variant="ghost" size="icon" onClick={logout}>
                  <LogOut className="h-5 w-5" />
                </Button>
              </div>
            </div>
          </header>

          {/* Page content */}
          <main className="flex-1 p-6 min-w-0 overflow-x-auto">
            <Outlet />
          </main>
        </div>
      </div>
    </div>
  );
}

function SidebarContent({
  location,
  onNavigate,
  isAdminUser,
}: {
  location: { pathname: string };
  onNavigate?: () => void;
  isAdminUser: boolean;
}) {
  const filteredNavigation = navigation.filter(
    (item) => !item.adminOnly || isAdminUser
  );

  return (
    <>
      <div className="flex items-center flex-shrink-0 px-4 mb-8">
        <h1 className="text-xl font-bold">VES Booking Admin</h1>
      </div>
      <nav className="flex-1 px-2 space-y-1">
        {filteredNavigation.map((item) => {
          const isActive = location.pathname === item.href;
          const label = item.getLabel ? item.getLabel(isAdminUser) : item.name;
          return (
            <Link
              key={item.name}
              to={item.href}
              onClick={onNavigate}
              className={`
                group flex items-center px-3 py-2 text-sm font-medium rounded-md
                ${
                  isActive
                    ? "bg-primary text-primary-foreground"
                    : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                }
              `}
            >
              <item.icon className="mr-3 h-5 w-5" />
              {label}
            </Link>
          );
        })}
      </nav>
    </>
  );
}
