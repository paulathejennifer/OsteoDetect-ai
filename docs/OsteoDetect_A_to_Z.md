# OsteoDetect — A to Z

## What is OsteoDetect
- OsteoDetect is a lightweight AI-assisted medical imaging application for detecting bone fractures in radiographs.
- It provides a static frontend for uploading images and a FastAPI backend that runs YOLOv8 inference and produces visualization (Grad-CAM), results images, and simple detection reports.

## Key capabilities
- Single-image fracture detection using a YOLOv8 model.
- Result image and Grad-CAM visualizations stored under `results/`.
- Simple REST endpoints for integration with other services.
- Static frontend that can run in the browser and call the hosted API.

## High-level architecture
- Frontend: static HTML/CSS/JS under `frontend/` (can be hosted on Vercel or any static host).
- Backend: Python FastAPI app at `backend/app.py` (serves API routes and mounts `results` and `uploads`).
- ML model: `backend/models/model.pt` — YOLOv8 weights used for inference.
- Deployment: recommended split — Vercel for frontend, Railway (or Docker) for backend.

## Components and responsibilities
- `frontend/` — user UI, drag-and-drop or browse to upload an image, shows detection progress and results.
- `backend/app.py` — loads YOLO, handles endpoints: `/`, `/status`, `/detect`, `/gradcam/{id}` and saves outputs in `backend/results/`.
- `backend/models/model.pt` — model file (not included in public repos unless licensed).
- `Dockerfile` — build instructions for consistent backend runtime (includes system libs needed for OpenCV).
- `requirements.txt` and `backend/requirements.txt` — python deps; `opencv-python-headless` is used for headless containers.

## Data flow (simple)
1. User uploads image via frontend → JS sends multipart POST to `POST /detect`.
2. Backend receives file into `uploads/`, runs YOLO inference.
3. Backend saves `result_image`, `gradcam_image`, and an `explanation.jpg`, and returns a JSON payload with paths to these files and detection metadata.
4. Frontend fetches the result URLs and displays images and detection list.

## Run locally (quick)
Prerequisites:
- Python 3.11
- A virtualenv (recommended)
- `pip install -r requirements.txt`

Commands (from repo root):

```powershell
# create and activate venv (Windows)
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
# Run backend
cd backend
uvicorn app:app --host 0.0.0.0 --port 8000
```

Open the frontend by opening `frontend/detect.html` in your browser (or host the `frontend` folder with a static server).

Notes:
- If you use a container, the `Dockerfile` installs `libgl1` and other system deps required by OpenCV.
- Keep local `.venv` out of the image (see `.dockerignore` and `.gitignore`).

## Deploy
- Frontend: use Vercel or any static host. In Vercel set the root directory to `frontend` and use the Static Site preset (no build) or choose a specific preset if you add a build step.
- Backend: Railway can build using the provided `Dockerfile` (recommended) or use the Python build with `requirements.txt` and `Procfile`.
- If deploying Docker, ensure the image contains system packages: `libgl1`, `libglib2.0-0`, `libsm6`, `libxext6`, `libxrender1` — these are required by `opencv` even when using `opencv-python-headless`.

Common deployment pitfalls
- `ImportError: libGL.so.1` — fix by installing `libgl1` in the image (Dockerfile already includes it).
- Accidental committing of local `.venv` — add `.venv/` to `.gitignore` and `.dockerignore`.
- Railway runtime not matching local Python version — pin `runtime.txt` and use Docker to ensure consistency.

## API reference (summary)
- `GET /` — root; basic welcome message.
- `GET /status` — health/status check.
- `POST /detect` — multipart form `file` — runs detection and returns JSON with keys: `result_image`, `gradcam_image`, `detections` (array), etc.
- `GET /results/<file>` — static files served from `results/` (backend mounts this directory).

Example result JSON (abridged):

```json
{
  "result_image": "/results/abcd_result.jpg",
  "gradcam_image": "/results/abcd_gradcam.jpg",
  "detections": [
    {"class": "fracture", "confidence": 0.92, "box": {"x1":10,"y1":20,"x2":100,"y2":200}}
  ]
}
```

## Model details
- Model: YOLOv8 (via `ultralytics` package).
- Weights file: `backend/models/model.pt`.
- Grad-CAM: backend uses image-processing to produce a visualization; timings depend on model size and hardware.
- Hardware: inference on CPU is supported but slower. For production, use a GPU-enabled host or a smaller model for speed.

## Security & privacy
- Uploaded images may contain PHI. Do not store or expose sensitive images in public deployments without appropriate consent and security.
- If you deploy to a public host, use HTTPS (Railway/Vercel provide TLS by default) and restrict storage access.
- Consider data retention policies and automatic deletion after a retention period.

## Troubleshooting
- If images do not display on the frontend:
  - Confirm `frontend/images/` contains the files referenced in HTML or use absolute URLs.
  - Open browser DevTools → Network to inspect image requests and ensure they return `200`.
- If `/detect` returns no result or error:
  - Check backend logs (Railway logs or Docker logs) for import errors (e.g. `libGL.so.1`) or model loading errors.
  - Confirm `model.pt` exists at `backend/models/model.pt` and is readable by the process.

## File structure (important files)
- `frontend/` — static site
  - `detect.html`, `detect-script.js` — upload UI and JS
  - `images/` — hero/team/sample images
- `backend/`
  - `app.py` — FastAPI app
  - `requirements.txt` — backend-specific deps
  - `models/model.pt`
  - `results/`, `uploads/`
- `Dockerfile`, `.dockerignore`, `Procfile`, `runtime.txt`, `requirements.txt`

## Contributing and maintenance
- Keep `requirements.txt` up to date; pin major versions when necessary.
- Run unit tests (add tests under `tests/`) and CI to validate builds.
- When upgrading `ultralytics` or `torch`, validate model compatibility locally before deploying.

## Contact
- Developer: Jennifer Olisakwe
- Repo: GitHub repository root for code and issues.

---

If you want, I can:
- add this file to the repo and commit/push it,
- expand any section (API examples, deployment steps, or admin commands),
- generate a short README version for the repo root.
