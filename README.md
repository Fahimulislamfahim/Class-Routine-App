# University Class Routine Vision Extractor & Timetable App

An intelligent, cross-platform Flutter application (Web & Desktop) that takes an uploaded university routine image, extracts the scheduled sessions into structured JSON using Google Gemini Multimodal Vision (`gemini-2.5-flash` / `gemini-3.7-flash`), and renders an interactive timetable with dynamic section/subgroup filtering, search, and calendar export.

---

## Key Features

- **Multimodal Gemini Vision Extraction**:
  - Automatically parses grid routines (Saturday through Friday) across standard university time slots.
  - Extracts course codes, full expanded titles, faculty initials, room numbers, class types (`lab` / `theory`), and section subgroups.
  - Strictly adheres to structured JSON schema using Gemini's native `responseSchema` API.
- **Dynamic Section & Subgroup Filtering**:
  - Automatically aligns filters to the routine's section (e.g. **Group A1 / A2** for Section A, **Group D1 / D2** for Section D, etc.).
  - Filter modes: *All Classes*, *Group 1 (Labs + Theory)*, *Group 2 (Labs + Theory)*, *Theory Only*, *Labs Only*.
- **Interactive Timetable & Agenda**:
  - **7-Day Weekly Grid View**: Full visual university timetable grid with color-coded courses, room indicators, and teacher initials.
  - **Daily Agenda View**: Mobile-friendly chronological schedule with day selector chips.
  - **Live Search**: Instant filtering by course code (e.g., `SE331`), course title, faculty initial, or room.
- **Image Comparison**:
  - Interactive, zoomable image modal to compare the extracted schedule side-by-side with the original routine.
- **Calendar & JSON Export**:
  - Export to Google / Apple / Outlook Calendar via recurring **iCalendar (`.ics`)** files.
  - Export structured timetable JSON for external integrations.
- **Manual Session Editor**:
  - Click any class card or empty grid slot to inspect, edit, or add sessions.
- **Modern UI & Dark Mode**:
  - Modern university teal/emerald aesthetic with seamless dark/light theme switching.

---

## Tech Stack

- **Framework**: Flutter 3.47+ / Dart 3.13+
- **AI / Multimodal Vision**: Google Gemini REST API (`generateContent`)
- **Key Packages**:
  - `http` - API requests
  - `file_picker` - Cross-platform file selection
  - `google_fonts` - Plus Jakarta Sans typography
  - `shared_preferences` - Local storage for API keys and saved routines
  - `intl` - Date and time formatting

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.47+ recommended)
- A Google Gemini API Key from [Google AI Studio](https://aistudio.google.com/)

### Installation & Running

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Fahimulislamfahim/Class-Routine-App.git
   cd Class-Routine-App
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Launch the application**:
   - **For Web (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **For Windows Desktop**:
     ```bash
     flutter run -d windows
     ```

5. **Build for production (Web)**:
   ```bash
   flutter build web
   ```

---

## License

MIT License. Built for university students and schedule automation.
