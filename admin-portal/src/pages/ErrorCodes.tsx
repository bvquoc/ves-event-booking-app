import { useEffect, useState } from "react";
import { errorCodeApi, ErrorCodeResponse } from "@/lib/api";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export default function ErrorCodes() {
  const [errorCodes, setErrorCodes] = useState<ErrorCodeResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadErrorCodes();
  }, []);

  const loadErrorCodes = async () => {
    try {
      const response = await errorCodeApi.getAllErrorCodes();
      setErrorCodes(response.result);
    } catch (error) {
      console.error("Failed to load error codes:", error);
    } finally {
      setLoading(false);
    }
  };

  const getHttpStatusColor = (status: number) => {
    if (status >= 200 && status < 300) return "text-green-600";
    if (status >= 400 && status < 500) return "text-yellow-600";
    if (status >= 500) return "text-red-600";
    return "text-gray-600";
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Error Codes</h1>
        <p className="text-muted-foreground">
          System error codes reference ({errorCodes.length} codes)
        </p>
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Code</TableHead>
                <TableHead>Message</TableHead>
                <TableHead>HTTP Status</TableHead>
                <TableHead>Category</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {errorCodes.map((errorCode) => (
                <TableRow key={errorCode.name}>
                  <TableCell className="font-medium font-mono">
                    {errorCode.name}
                  </TableCell>
                  <TableCell className="font-mono">{errorCode.code}</TableCell>
                  <TableCell>{errorCode.message}</TableCell>
                  <TableCell>
                    <span
                      className={`font-semibold ${getHttpStatusColor(
                        errorCode.httpStatus
                      )}`}
                    >
                      {errorCode.httpStatus}
                    </span>
                  </TableCell>
                  <TableCell>{errorCode.category || "-"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
