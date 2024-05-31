import { NextRequest, NextResponse } from "next/server";
import fetch from "node-fetch";

const LOG_FILE_URL = process.env.LOG_FILE_URL;

export async function GET(req: NextRequest) {
  try {
    const LOG_FILE_URL = process.env.LOG_FILE_URL;
    if (!LOG_FILE_URL) {
      throw new Error("LOG_FILE_URL is not defined");
    }
    const response = await fetch(LOG_FILE_URL);
    if (!response.ok) {
      throw new Error("Failed to fetch logs");
    }
    const logData = await response.text();
    return new NextResponse(logData, {
      headers: { "Content-Type": "text/plain" },
    });
  } catch (err) {
    console.error("Error fetching logs:", err);
    return NextResponse.json(
      { error: "Unable to fetch logs" },
      { status: 500 }
    );
  }
}
