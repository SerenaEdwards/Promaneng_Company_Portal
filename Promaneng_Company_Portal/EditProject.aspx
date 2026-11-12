<%@ Page Title="Edit Project" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditProject.aspx.cs" Inherits="Promaneng_Company_Portal.EditProject" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <div class="card shadow-sm">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <span class="fw-bold"><i class="bi bi-pencil-square me-1"></i> Edit Project Details</span>
            <a href="Projects.aspx" class="btn btn-sm btn-light">&larr; Back</a>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-bold">Project Name</label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-bold">Estimated Cost</label>
                    <asp:TextBox ID="txtEstCost" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-bold">Estimated Time (Days)</label>
                    <asp:TextBox ID="txtEstTime" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-12">
                    <label class="form-label">Street Address</label>
                    <asp:TextBox ID="txtStreet" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">City</label>
                    <asp:TextBox ID="txtCity" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">Parish</label>
                    <asp:TextBox ID="txtParish" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">Country</label>
                    <asp:TextBox ID="txtCountry" runat="server" CssClass="form-control" />
                </div>
            </div>
            <div class="mt-3 text-end">
                <asp:Button ID="btnUpdateProject" runat="server" Text="Save Changes" CssClass="btn btn-brand-ocean" OnClick="btnUpdateProject_Click" />
            </div>
        </div>
    </div>
</asp:Content>

