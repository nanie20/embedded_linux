import { NextRequest, NextResponse } from "next/server";
import fetch from "node-fetch";

const PHOTO_DIR_URL = process.env.PHOTO_DIR_URL;

export async function GET(
  req: NextRequest,
  { params }: { params: { date: string; filename: string } }
) {
  const { date, filename } = params;
  const jsonFilename = filename.replace(".jpg", ".json");
  try {
    const response = await fetch(
      `${PHOTO_DIR_URL}/metadata/${date}/${jsonFilename}`
    );
    if (!response.ok) {
      throw new Error("Failed to fetch metadata");
    }
    const metadata = await response.json();
    return NextResponse.json(metadata);
  } catch (err) {
    console.error("Error fetching metadata:", err);
    return NextResponse.json(
      { error: "Unable to fetch metadata" },
      { status: 404 }
    );
  }
}
