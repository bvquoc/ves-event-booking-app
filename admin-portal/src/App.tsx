import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { Toaster } from "react-hot-toast";
import { AuthProvider } from "./contexts/AuthContext";
import { ProtectedRoute } from "./components/ProtectedRoute";
import { AdminRoute } from "./components/AdminRoute";
import Layout from "./components/Layout";
import Login from "./pages/Login";
import CheckIn from "./pages/CheckIn";
import Users from "./pages/Users";
import Events from "./pages/Events";
import Tickets from "./pages/Tickets";
import Orders from "./pages/Orders";
import Notifications from "./pages/Notifications";
import Vouchers from "./pages/Vouchers";
import Favorites from "./pages/Favorites";
import Roles from "./pages/Roles";
import Permissions from "./pages/Permissions";
import Cities from "./pages/Cities";
import Venues from "./pages/Venues";
import ErrorCodes from "./pages/ErrorCodes";

function App() {
  return (
    <BrowserRouter basename="/admin">
      <AuthProvider>
        <Toaster />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/check-in"
            element={
              <ProtectedRoute>
                <CheckIn />
              </ProtectedRoute>
            }
          />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Navigate to="/events" replace />} />
            <Route
              path="users"
              element={
                <AdminRoute>
                  <Users />
                </AdminRoute>
              }
            />
            <Route path="events" element={<Events />} />
            <Route path="tickets" element={<Tickets />} />
            <Route
              path="orders"
              element={
                <AdminRoute>
                  <Orders />
                </AdminRoute>
              }
            />
            <Route path="notifications" element={<Notifications />} />
            <Route path="vouchers" element={<Vouchers />} />
            <Route path="favorites" element={<Favorites />} />
            <Route
              path="roles"
              element={
                <AdminRoute>
                  <Roles />
                </AdminRoute>
              }
            />
            <Route
              path="permissions"
              element={
                <AdminRoute>
                  <Permissions />
                </AdminRoute>
              }
            />
            <Route
              path="cities"
              element={
                <AdminRoute>
                  <Cities />
                </AdminRoute>
              }
            />
            <Route path="venues" element={<Venues />} />
            <Route
              path="error-codes"
              element={
                <AdminRoute>
                  <ErrorCodes />
                </AdminRoute>
              }
            />
          </Route>
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
