# Group 2 – Q&A filters & local password reset

## Q&A

- Customer → My Q&A: All, Pending, Approved, Rejected.
- Admin → Q&A Conversations: All, Needs Review, Approved, Rejected.
- A conversation is Pending when a question or reply awaits approval; Approved when all visible content is approved; Rejected when a question or reply was rejected.
- Moderation returns admin to the selected filter. Pending private replies are visible only to their author and admins.

## Forgot password (local demo)

The Forgot Password screen requires the **registered username and email address**. The server verifies that both values belong to the same active user in SQL Server. When they match, the browser session can set a new password for **5 minutes**. The new password is stored as a PBKDF2 hash, not plain text.

No email, SMTP settings, recovery codes, or reset links are needed. The session is cleared after a successful reset or expiration. The user then logs in with the new password.

This verification uses account details, **not proof of mailbox ownership**. It is intended for the local classroom demonstration only; do not expose this password-reset flow on a public website.

### Database

- New database: run `database.sql`. No reset-specific columns or email settings are needed.
- Existing database: no schema migration is needed for this change. Old unused reset-token columns can remain; the application no longer maps or uses them.
- `migration_existing.sql` is for users upgrading from older database versions that lack Q&A tables.

### Functional checks

1. In My Q&A and Admin → Q&A, select each status and verify the list updates.
2. Open Forgot Password and enter matching username/email of an active demo user.
3. Set matching new passwords of 8–100 characters; sign in with the new password.
4. Verify the old password no longer works.
5. Try incorrect details or a disabled account: reset must be rejected.
6. Access `/reset-password` in a new browser session: it must return to Forgot Password.
7. Reopen the reset page after success or after 5 minutes: the reset should no longer be available.
