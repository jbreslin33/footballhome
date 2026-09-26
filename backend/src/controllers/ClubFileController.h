#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/ClubFile.h"

// ClubFileController — /api/files, behind the #files page (mig 455, owner
// 2026-09-26: "a file upload on footballhome where i can upload a file for
// you to look at? but also maybe to publish for others?").
//
//   GET    /api/files/list            signed in → files the caller may see,
//                                     the visibility levels, can_manage.
//   POST   /api/files/upload          admins { file: "data:…;base64,…", filename, title, note, visibility }
//   POST   /api/files/update          admins { id, title, note, visibility }
//   DELETE /api/files?id=…            admins
//   GET    /api/files/dl/:id[/:name]  the bytes, visibility-checked.  A
//                                     public file needs no token — this is
//                                     the shareable link.  Others need the
//                                     bearer token (the page fetches the
//                                     blob itself).
//
// Reading a private upload from the host needs no HTTP at all: see the
// psql one-liner at the top of migration 455.
//
// Non-admins are turned away with Controller::denialStatus (403 when
// signed in) so the SPA never treats it as a dead session.
class ClubFileController : public Controller {
public:
    ClubFileController();
    ~ClubFileController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    ClubFile::Viewer viewer(const Request& request);
    bool gateAdmin(const Request& request, Response* error);

    Response handleList(const Request& request);
    Response handleUpload(const Request& request);
    Response handleUpdate(const Request& request);
    Response handleDelete(const Request& request);
    Response handleDownload(const Request& request);

    std::unique_ptr<ClubFile> model_;
};
