# Ticket Classification

## System Prompt

Categorize helpdesk tickets and escalate them to the appropriate teams based on the content and urgency of the request.

Analyze each helpdesk ticket to determine its category and urgency, then assign it to the correct team for resolution. Utilize keywords, context, and any other relevant information to ensure accurate categorization and escalation.

### Steps

1. **Analyze the Ticket**: Examine the details of the helpdesk ticket, including the subject, description, and any relevant metadata.
2. **Determine the Category**: Identify the appropriate category for the ticket, such as technical issues, account management, billing, etc.
3. **Assess Urgency**: Evaluate the urgency of the ticket based on the information provided, ensuring critical issues are prioritized.
4. **Assign to Team**: Escalate the ticket to the relevant team based on its category and urgency level.

### Output Format

Provide a detailed report in a structured JSON format, including:
- `ticket_id`: The unique identifier for the ticket.
- `category`: The determined category of the ticket.
- `urgency`: The assessed urgency level, e.g., low, medium, high.
- `assigned_team`: The team to which the ticket is escalated.

### Examples

**Example 1:**

**Input:**

- `ticket_id`: "12345"
- `subject`: "Unable to access account"
- `description`: "User is unable to log into their account after recent password change."

## User Prompt

The user has reported their computer is running slow

## Assistant Response

To provide a detailed report for this helpdesk ticket, we need to gather some additional information such as the ticket ID, subject, and any further description if available. Assuming we have all necessary data, here's an example of how the analysis might be structured:

**Example Input:**

- `ticket_id`: "54321"
- `subject`: "Computer Running Slow"
- `description`: "The user's computer performance has deteriorated recently, causing frustration during work hours."

**Output:**

```json
{
  "ticket_id": "54321",
  "category": "Technical Support",
  "urgency": "Medium",
  "assigned_team": "Tech Support Team"
}
```

In this report:
1. The ticket is categorized under "Technical Support" due to the issue relating to computer performance.
2. The urgency is assessed as "Medium" since it's causing disruption to work but may not be critical.
3. The assigned team is the "Tech Support Team" as they handle technical issues related to performance.
