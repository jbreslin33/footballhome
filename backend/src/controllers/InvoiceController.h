#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/Invoice.h"

// InvoiceController — /api/invoices, behind the #invoices page (mig 465,
// owner 2026-09-27: "make it easier to make invoices for lighthouse").
// Club / super admins only; a signed-in non-admin gets denialStatus (403)
// so the SPA never treats it as a dead session.
//
//   GET    /api/invoices/board          issuers, categories, bill-to,
//                                       invoices with totals, open plans
//   POST   /api/invoices/new            { issuer_id, date? } → { id }
//   GET    /api/invoices/:id            one sheet with lines + total
//   GET    /api/invoices/public/:slug   the same sheet, no sign-in (mig 480) — invoice.html?k=<slug>
//   POST   /api/invoices/:id/update     { date?, number?, is_final?, note? }
//   POST   /api/invoices/:id/line       { id?, category, description, quantity, rate, amount? }
//   POST   /api/invoices/:id/shift      { id?, date, start, end, note }  hours by day (mig 469)
//   DELETE /api/invoices/shift?id=      one day
//   POST   /api/invoices/:id/fill       copy the issuer's weekly default onto the period ({ force? })
//   POST   /api/invoices/default        { id?, issuer_id, day_index 0-13, start|end or hours, note }  the usual 2 weeks (mig 470/477)
//   DELETE /api/invoices/default?id=
//   DELETE /api/invoices/line?id=       one line
//   POST   /api/invoices/plan           { issuer_id, invoice_id, category, description, total_amount, installment_count, show_total }
//   DELETE /api/invoices/plan?id=       stop a plan (past lines keep their text)
//   POST   /api/invoices/issuer         { id, address, city_state_zip, phone, payable_to, duty_description, hourly_rate }
//   DELETE /api/invoices?id=            one invoice
class InvoiceController : public Controller {
public:
    InvoiceController();
    ~InvoiceController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    bool gate(const Request& request, Response* error);

    Response handleBoard(const Request& request);
    Response handleRefFees(const Request& request);
    Response handleAddRefFees(const Request& request);
    Response handleNew(const Request& request);
    Response handleGet(const Request& request);
    Response handlePublic(const Request& request);
    Response handleUpdate(const Request& request);
    Response handleLine(const Request& request);
    Response handleDeleteLine(const Request& request);
    Response handleShift(const Request& request);
    Response handleDeleteShift(const Request& request);
    Response handleFill(const Request& request);
    Response handleDefault(const Request& request);
    Response handleDeleteDefault(const Request& request);
    Response handlePlan(const Request& request);
    Response handleDeletePlan(const Request& request);
    Response handleIssuer(const Request& request);
    Response handleDelete(const Request& request);

    std::unique_ptr<Invoice> model_;
};
