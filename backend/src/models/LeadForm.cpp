#include "LeadForm.h"

#include <sstream>

#include "../database/Database.h"

void LeadForm::replaceActive(const std::vector<std::string>& formIds) {
    auto db = Database::getInstance();

    if (formIds.empty()) {
        db->query("DELETE FROM lead_forms");
        return;
    }

    std::ostringstream values;
    for (size_t i = 0; i < formIds.size(); ++i) {
        if (i) values << ",";
        values << "(" << db->escape(formIds[i]) << ")";
    }

    std::ostringstream sql;
    sql << "WITH new_ids(form_id) AS (VALUES " << values.str() << "), "
           "del AS ( "
           "  DELETE FROM lead_forms WHERE form_id NOT IN (SELECT form_id FROM new_ids) "
           ") "
           "INSERT INTO lead_forms (form_id, checked_at) "
           "SELECT form_id, NOW() FROM new_ids "
           "ON CONFLICT (form_id) DO UPDATE SET checked_at = NOW()";

    db->query(sql.str());
}
