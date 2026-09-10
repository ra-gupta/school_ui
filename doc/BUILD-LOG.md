# Build log

Rebuild of the "Multi-School ERP" product (multischoolerp.com — Laravel 12 + Flutter, 38 modules,
6 apps) as **Rails 8 + Flutter**. Running record of decisions, gotchas, and where to pick up.

Last session: 2026-09-09.

---

## Where to pick up

**Next task: build the remaining 35 web modules on the `Manageable` foundation, then the Flutter app.**

The generic CRUD + API foundation is written and loads clean (`bin/rails zeitwerk:check` passes),
but **nothing uses it yet**:

- [ ] No routes for `/api/v1/*` — the API controllers exist but are unreachable. Add the namespace,
      including `post "session"`, `get "me"`, and the catch-all `:resource` routes.
- [ ] No model calls `manage ...` yet, and no `ResourceController` subclass exists.
- [ ] Dashboard was redesigned (charts, quick-access grid) and the `_stat` partial bug was fixed,
      but **the screenshot suite has not been re-run since** — verify first thing.

Per-module work is now: a migration + a model with a `manage` block + a two-line controller +
one route line. Views and JSON come free.

---

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
- **`bin/rails zeitwerk:check`** is the cheap way to catch class-body errors without a 2-minute
  Selenium run. Use it after writing controllers.

---

## State

### Done — Phase 1, the spine
Multi-tenancy (`Tenanted` + `Current.school`), Rails 8 auth, RBAC, Apps Center registry
(`config/modules.yml`, 44 modules), and the domain: schools, academic years, grades/sections/
subjects, students + guardians, staff + departments, enrollments, attendance + biometric devices/
punches, fees (heads → structures → invoices → payments), timetable, exams + results, homework,
notices.

### Done — Phase 2, 9 of 44 modules
Students, Academics, Attendance, Exams, Fees, HR/Staff, Homework, Timetable, Notices, plus the
super-admin school switcher. 21 screens, all covered by `bin/rails test:system`.

### Written but unwired
`Manageable` concern, `ResourceController` + `app/views/resource/*`, `Api::V1::{Base,Sessions,
Users,Resources}Controller`. Loads clean; no routes, no subclasses, no `manage` declarations.

### Not started
The other 35 modules, the Flutter app, the ZKTeco `/iclock/cdata` endpoint, payment gateways,
file uploads (ActiveStorage), PDF receipts/report cards, push notifications, parent-teacher chat.

Flutter 3.47.2 is installed at `~/flutter` (add `~/flutter/bin` to PATH).

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
