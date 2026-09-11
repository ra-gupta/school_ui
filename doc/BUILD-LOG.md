# Build log

Rebuild of the "Multi-School ERP" product (multischoolerp.com — Laravel 12 + Flutter, 38 modules,
6 apps) as **Rails 8 + Flutter**. Running record of decisions, gotchas, and where to pick up.


---

## Notifications

Events are catalogued in `SchoolEvent`; `Notifications::Notifier` renders the school's
template for an event and channel (falling back to the event's default wording) and queues
one `MessageLog` per reachable channel, which `Notifications::DeliveryJob` then delivers.

- **Adding a vendor is one class.** `Notifications::Channel` subclasses implement `#deliver`.
  Email works today; SMS, WhatsApp and push raise `NotConfigured` until an account is
  chosen, and the job **discards** rather than retries on that — an unconfigured school
  must not fill the queue.
- **`dedupe_key` is the "tell them once" mechanism**, enforced by a partial unique index on
  `(school_id, user_id, channel, dedupe_key)`. Every trigger needs this guard; doing it in
  the database makes it exact and race-free instead of each job inventing its own query.
- **Preferences are two array columns on `users`** (`notification_channels`, `muted_events`),
  not a preferences table — until per-event channel choice is actually asked for.
- Push has no device-token store yet, so it resolves to no address and is skipped rather
  than queued to fail. That store is part of the Flutter work.

**The AI assistant was built and then dropped** (PR #7, closed) — per-question cost, an
external dependency, a key to rotate, and a leak surface, for answers the dashboard already
gives exactly and for free. Its registry entry is removed; 43 modules remain.

## Live tracking

Driver fix → `POST /api/v1/driver/location` → `vehicle_locations` row → `after_create_commit`
broadcasts on `VehicleChannel` → every open map moves the marker. No refresh, no polling.

- **What makes it feel live** is in `app/javascript/controllers/live_map_controller.js`: the
  marker *glides* from its last position to the new one over the real gap between fixes
  (capped at 6s), the arrow rotates to the heading, and the ETA / "updated 3s ago" tick on
  their own clock. Without the glide it is a marker that jumps every few seconds.
- **Who may watch** is decided in `VehicleChannel#subscribed`, not the client: staff with
  `transport.read` see the fleet; a family sees only the bus their child rides. Same rule as
  chat.
- **Leaflet is vendored** (`vendor/javascript/leaflet.js`, `app/assets/stylesheets/leaflet.css`,
  `app/assets/images/leaflet/`) for the same reason the font is: the campus may be offline.
  Map *tiles* still come from tile.openstreetmap.org — self-hosting those is a real project.
- **Development uses Solid Cable, not `async`.** `async` is in-process only, so a broadcast
  from `bin/rails transport:simulate` in one terminal would never reach a browser served by
  `bin/dev` in another. Dev has its own `school_development_cable` database; with
  `structure.sql` format, `db:prepare` needs `db/cable_structure.sql`, which now exists.
- **`bin/rails transport:simulate`** drives a bus along its route so the map can be watched
  without the Flutter app. **`script/live_tracking_check.rb`** is the end-to-end proof — a fix
  from another process moving the marker in a real browser over the socket — and needs a
  running dev server, so it is not in CI.
- **Retention:** `transport:prune_locations` runs nightly — one fix per minute after a week,
  nothing after a month. A bus posting every few seconds writes thousands of rows a day.
- **ETA is straight-line distance ÷ speed** to the nearest stop, and "next stop" is simply
  the nearest. Honest, and marked `ponytail:` — road-snapped routing (OSRM) and
  route-order awareness are the upgrades if it misleads.

**Importmap was never installed until this branch.** `config/importmap.rb` did not exist, so
`javascript_importmap_tags` rendered nothing and **no JavaScript ran in the app at all** —
Turbo, Stimulus, Action Cable, none of it. Every screen had been server-rendered HTML with
plain form submits. Now installed and verified by the suite.

## Where to pick up

Last session: 2026-09-10. `main` is green, no open branches, no open PRs.

**All 43 web modules are built.** The next piece is the **Flutter app**, and it is blocked on
nothing — the API is already in place (auth incl. mobile-number login, dashboard shaped per
role, attendance marking, fees + payment, timetable, chat, driver GPS, plus generic JSON CRUD
for every `manage`d model). Flutter 3.47.2 is installed at `~/flutter` (add `~/flutter/bin`
to PATH).

**Two decisions were still open when we stopped:**

1. **SMS / WhatsApp vendor** — MSG91 or Gupshup (India-focused, cheaper at volume) versus
   Twilio (one vendor for both, easier setup, pricier). Real delivery on those channels is
   blocked on this; the adapter is one class either way
   (`app/services/notifications/sms_channel.rb`).
2. **Whether to start the Flutter app** before or after wiring that vendor.

### Known gaps, in rough priority order

- **No device-token store**, so push resolves to no address and is skipped. Build it with the
  Flutter app — it is the reason push exists.
- **Driver app.** The server side of live tracking is done and proven; what posts the fixes
  is the Flutter driver screen — `geolocator` in the background, every ~5s while a trip is
  active, surviving the screen being off. That is the hard half.
- **Password reset is email-only.** A parent who signs in with a mobile number and has no
  email address cannot reset their own password. Needs an SMS OTP path, so it waits on the
  vendor decision.
- **Bus proximity is a straight-line distance and a linear scan** over the vehicle's stops,
  run on every driver ping. Fine at a handful of stops; `ponytail:` comment carries the
  upgrade path.
- **No deploy setup.** The app was generated with `--skip-kamal --skip-docker`, and CI has no
  deploy job for that reason.
- **Screenshots are in `main`'s history** from the first import, though no longer tracked.
  Removing them needs another history rewrite — offered, not done.

### How this repo is worked

Branch → PR → CI green → merge → delete branch. Git identity is **repo-local**
(`Rahul Gupta <rahul.r.gupta97@gmail.com>`); the global config is deliberately untouched.
**No `Co-Authored-By` trailers.** Screenshots go to `tmp/screenshots/` and are never
committed.


## Decisions

| Question | Call | Why |
|---|---|---|
| Multi-tenancy | Single DB, `school_id` + `default_scope` | Matches the original; leaking across schools becomes the *hard* path |
| Web UI | Rails 8 + Hotwire + **Tailwind 4** | See below — not Material |
| Mobile UI | Flutter + **Material** | Built into Flutter; touch targets are correct there |
| Schema format | `:sql` (`db/structure.sql`) | Keeps Postgres-native `text[]`, partial indexes |
| Mobile apps | **One** Flutter app, role-driven UI | Parent/student/staff/driver are the same screens with different permissions |
| Biometric agent | Skipped the .NET Windows exe | ZKTeco ADMS is plain HTTP — Rails can serve `/iclock/cdata` |
| RBAC | `text[]` of `"module.action"` + `User#can?` | ~10 lines; no Pundit/CanCan/Spatie |
| Pagination | `limit`/`offset` helper | 6 lines beats a gem |
| Charts | Hand-built CSS/flex marks | No chart library needed for bars + a stacked bar |
| Font | Inter, self-hosted, lifted from `../mybilling` | Includes `inter-rupee.woff2` — ₹ is outside every standard subset |
| API | Generic, driven by the same `manage` declaration | One declaration → web CRUD + JSON CRUD, so the app can't drift from the web |
| API auth | Bearer = signed id of a normal `Session` row | Web and app sessions are the same object; revoking one revokes both |

### Why Tailwind and not Material (web)

An ERP is dense tables, filter bars and forms. Material Web's components are spacious by design
(built for touch), ship no data grid, and make every screen look like a Google product. Tailwind
gives density control, which is the thing that matters here. Material is still the right choice
inside Flutter.

### Chart colours (validated, do not eyeball)

Validator: `dataviz` skill's `scripts/validate_palette.js` (copy it into a dir with
`{"type":"module"}` in package.json, and keep the filename — its CLI guard checks for
`validate_palette.js`).

- **Single-series bars** (fee collection): sequential blue `#2a78d6`, dim step `#9ec5f4`.
- **Attendance stacked bar**: status palette in the order **good `#0ca30c` → warning `#fab219` →
  critical `#d03b3b` → serious `#ec835a`**. That ordering is not cosmetic — it is the only one of
  the four tried that clears both the CVD floor and the normal-vision floor on adjacent pairs.
  The obvious order (present/late/leave/absent) puts warning next to serious and **fails**
  (normal-vision ΔE 13.6, floor is 15).
- `#fab219` is below 3:1 on white by design; the mitigation is the per-segment direct label +
  legend glyph, which is why every segment is labelled. Don't "clean up" the labels.
- Part-to-whole is a **stacked bar, never a donut** (per the skill's form heuristic).
- Tokens live in `app/assets/stylesheets/application.css` under `/* Chart tokens */`.
- Dark mode: deliberately skipped — the app chrome is light-only. Add both together, not charts alone.

---

## Gotchas hit (don't re-derive these)

- **`def foo = bar if cond` is a trap.** The modifier applies to the `def` itself, so `bar` is
  evaluated in the class body. **This has bitten three times** (`SchoolsController`,
  `StudentsController#edit`, `Api::V1::BaseController#authorize!`). Guard command:
  `grep -rn "^\s*def .* = .* \(if\|unless\) " app/`
- **`json` 3.0.2 breaks `ActiveSupport::JSON.decode`** (`JSON.parse` arity). Pinned
  `gem "json", "~> 2.7"`. Symptom is a bogus `ArgumentError: wrong number of arguments
  (given 2, expected 1)` raised from `restore_transaction_record_state`, masking the real error.
- **libvips 8.12 is too old for Rails 8 ActiveStorage** — it refuses to boot with `ruby-vips`
  present. Dropped `image_processing`; add back (mini_magick backend) when ID cards need variants.
- **`authenticate_by` does a global `find_by`** — per-school-unique emails could resolve the wrong
  tenant. Login identity is now unique platform-wide.
- **Tailwind 4** needs explicit `@source` lines pointing at `app/views`, and its entry file must
  live at `app/assets/tailwind/application.css`.
- **Capybara `assert_no_text` passes on a race** — it succeeds while the page is still loading. It
  hid a failed login for two runs. Assert something positive (`assert_text user.name`).
- **Don't switch users inside one system test.** Turbo's cached snapshot makes it flaky. One test
  per user, with `use_transactional_tests = false` so seeds persist and reruns are fast.
- **`bin/rails runner` + `ActionDispatch::Integration::Session`** needs `s.host = "localhost"` (dev
  host allowlist) and still trips CSRF. Not worth it — use the system test.
- **The system suite leaves seeded rows in the test database on purpose**
  (`use_transactional_tests = false`, so reruns are fast). Other tests must not assume an
  empty database: the seeds hand out `+9197/98/99…` phone numbers, so unit tests use the
  `+9190` range. A unit test that picked a seeded number passed alone and failed after a
  system run.
- **Run `bin/rails test`, not just `bin/rails test:system`.** The auth tests generated by
  `rails generate authentication` referenced the `users` fixture that was deleted on day
  one, so they were broken for a week and only surfaced when CI first ran the full task.
- **Join-table models have no `school_id`.** `ExamSchedule`, `ExamResult`, `SubjectAssignment`
  and friends are reached only through a tenant-scoped parent, so they are not `Tenanted` and a
  bare `ExamSchedule.limit(6)` crosses schools. Scope through the parent
  (`ExamSchedule.where(exam_id: Exam.ids)`), not by luck.
- **Constants inside a `Data.define` block land on `Object`, not the class.** `SchoolModule`
  and `SchoolEvent` both declared `ALL`, and the second to load silently clobbered the
  first — `SchoolModule.all` started returning events. Declare them in a reopened
  `class Foo ... end` body instead. The screenshot suite caught this; nothing else would have.
- **`bin/rails zeitwerk:check`** is the cheap way to catch class-body errors without a 2-minute
  Selenium run. Use it after writing controllers.

---

## State

### The spine
Multi-tenancy (`Tenanted` + `Current.school`), Rails 8 auth with mobile-number login, RBAC
(`text[]` of `module.action` + `User#can?`), and the Apps Center registry
(`config/modules.yml`, 43 modules).

### One declaration per module
A model's `manage` block states its columns, form fields, search and ordering.
`ResourceController` renders it as HTML (subclasses inherit `app/views/resource/*` through
Rails' view inheritance) and `Api::V1::ResourcesController` serves the same declaration as
JSON — so a module cannot have a web screen the app's API lacks. Adding one is a migration,
a `manage` block, a two-line controller and a route line.

### All 43 modules built
Core: students, academics, attendance, exams, fees, HR, homework, timetable, notices.
Operations: library, transport + live GPS, hostel, inventory, asset register, front office,
gate pass, health, CCTV, campus workers, biometric devices.
People & finance: admissions CRM, certificates, ID cards, payroll, accounts.
Communications: messaging, PTM, surveys, knowledge base, website pages, greetings, chat.
Academic: online exams (CBT), lesson planner, CBC assessment, live classes, study centre,
digital evaluation.
System: compliance, support tickets, backups, storage centre, reports + CSV export.

Plus the super-admin school switcher, the dashboard, and notifications (see above).
~60 screens, every one covered by `bin/rails test:system`.

### JSON API
`/api/v1` — Bearer token is the signed id of an ordinary `Session` row, so web and app
sessions are the same object and revoking one revokes both. Bespoke endpoints for login,
`me`, a role-shaped dashboard, attendance marking, timetable, fees + payment, chat and
driver GPS; generic CRUD for every `manage`d model.

### Not started
The Flutter app. The ZKTeco `/iclock/cdata` ADMS endpoint (Rails can serve it directly — no
Windows agent). Payment gateway integration (the fee flow records payments but does not take
them). PDF receipts and report cards.

---

## Running it

```bash
cd web
bin/rails db:prepare db:seed
bin/dev                      # http://localhost:3000
bin/rails test:system        # smoke test + regenerates tmp/screenshots/
bin/rails zeitwerk:check     # fast "does everything load"
```

Logins (password `password`): `super@erp.test` · `principal@springfield.test` ·
`teacher1@springfield.test` · `parent1@springfield.test`
