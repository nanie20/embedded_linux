"use client";
import React, { useEffect, useState } from "react";

const Logs: React.FC = () => {
  const [logs, setLogs] = useState<string>("");

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const res = await fetch("/api/logs");
        if (!res.ok) {
          throw new Error("Failed to fetch logs");
        }
        const logData = await res.text();
        const logEntries = logData.split("\n").reverse().join("\n");
        setLogs(logEntries);
      } catch (error) {
        console.error("Error fetching logs:", error);
      }
    };

    // Fetch logs immediately on component mount
    fetchLogs();

    // Set up interval to fetch logs every 1 minute
    const intervalId = setInterval(fetchLogs, 60000);

    // Clean up the interval on component unmount
    return () => clearInterval(intervalId);
  }, []);

  return (
    <div className="flex flex-col items-center">
      <h1 className="text-center text-2xl font-bold my-4">Server Logs</h1>
      <div className="bg-white p-4 border border-gray-300 mt-4 max-w-4xl w-full whitespace-pre-wrap break-words">
        <pre>{logs}</pre>
      </div>
    </div>
  );
};

export default Logs;
