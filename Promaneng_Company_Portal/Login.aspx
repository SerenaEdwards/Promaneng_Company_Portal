<%@ Page Title="Internal Login" Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Promaneng_Company_Portal.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - Promaneng Internal Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
    <link href="~/Content/Site.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-wrapper d-flex align-items-center justify-content-center p-3">
            <div class="card login-card shadow-lg">
                <div class="login-header">
                    <i class="bi bi-building-gear text-warning fs-1"></i>
                    <h4 class="fw-bold mt-2 mb-0">PROMANENG</h4>
                    <small class="opacity-75">Internal Operations &amp; Engineering Portal</small>
                </div>

                <div class="card-body p-4 bg-white">
                    <asp:Label ID="lblLoginError" runat="server" EnableViewState="false"></asp:Label>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Access Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select">
                            <asp:ListItem Text="System Admin (Full Access)" Value="SystemAdmin" />
                            <asp:ListItem Text="HR Admin (Unmasked PII &amp; Staff)" Value="HR_Admin" />
                            <asp:ListItem Text="Site Manager (Projects &amp; Fleet)" Value="db_SiteManager" />
                            <asp:ListItem Text="Accountant (Budgets &amp; Spend)" Value="db_Accountant" />
                        </asp:DropDownList>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">SQL Login / Username</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="e.g. HRAdminLogin"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvUser" runat="server" ControlToValidate="txtUsername"
                            ErrorMessage="Username is required." CssClass="text-danger small" Display="Dynamic" />
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-bold">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword"
                            ErrorMessage="Password is required." CssClass="text-danger small" Display="Dynamic" />
                    </div>

                    <div class="d-grid">
                        <asp:Button ID="btnLogin" runat="server" Text="Sign In to Portal" CssClass="btn btn-brand-gold py-2" OnClick="btnLogin_Click" />
                    </div>

                    <div class="text-center mt-3">
                        <small class="text-muted"><i class="bi bi-shield-lock me-1"></i>Authorized Personnel Only &bull; RBAC Enforced</small>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>