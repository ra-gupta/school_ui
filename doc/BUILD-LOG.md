# Build log

Rebuild of the "Multi-School ERP" product (multischoolerp.com — Laravel 12 + Flutter, 38 modules,
6 apps) as **Rails 8 + Flutter**. Running record of decisions, gotchas, and where to pick up.

Last session: 2026-09-09.

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

### Done — Phase 1, the spine
Multi-tenancy (`Tenanted` + `Current.school`), Rails 8 auth, RBAC, Apps Center registry
(`config/modules.yml`, 44 modules), and the domain: schools, academic years, grades/sections/
subjects, students + guardians, staff + departments, enrollments, attendance + biometric devices/
punches, fees (heads → structures → invoices → payments), timetable, exams + results, homework,
notices.

### Done — 38 of 44 modules
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
