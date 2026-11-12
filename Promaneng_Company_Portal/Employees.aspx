<%@ Page Title="Employee Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employees.aspx.cs" Inherits="Promaneng_Company_Portal.Employees" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <!-- SKILLS INVENTORY & SEARCH (vw_EmployeeSkillAvailability) -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <span class="fw-bold"><i class="bi bi-person-badge-fill me-1"></i> Staff Directory &amp; Skills Inventory</span>
            <div class="d-flex gap-2">
                <asp:TextBox ID="txtSkillSearch" runat="server" CssClass="form-control form-control-sm" placeholder="Filter by skill..." />
                <asp:Button ID="btnSearchSkill" runat="server" Text="Filter" CssClass="btn btn-sm btn-brand-gold" OnClick="btnSearchSkill_Click" CausesValidation="false" />
                <asp:Button ID="btnResetSearch" runat="server" Text="Reset" CssClass="btn btn-sm btn-light" OnClick="btnResetSearch_Click" CausesValidation="false" />
            </div>
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvEmployees" runat="server" AutoGenerateColumns="False" CssClass="table table-striped table-hover m-0 align-middle" OnRowCommand="gvEmployees_RowCommand">
                <Columns>
                    <asp:BoundField DataField="EmployeeID" HeaderText="ID" />
                    <asp:BoundField DataField="FullName" HeaderText="Full Name" />
                    <asp:BoundField DataField="TRN" HeaderText="TRN (Masked/Unmasked)" />
                    <asp:BoundField DataField="DepartmentName" HeaderText="Department" />
                    <asp:BoundField DataField="JobType" HeaderText="Job Type" />
                    <asp:BoundField DataField="SkillSet" HeaderText="Skills" />
                    <asp:BoundField DataField="AvailabilityStatus" HeaderText="Availability" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnProfile" runat="server" CommandName="ViewProfile" CommandArgument='<%# Eval("EmployeeID") %>' CssClass="btn btn-sm btn-View-Profile me-1">
                                <i class="bi bi-eye-fill"></i> Profile
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditEmployee" CommandArgument='<%# Eval("EmployeeID") %>' CssClass="btn btn-sm btn-Edit-Client">
                                <i class="bi bi-pencil-square"></i> Edit
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- EMPLOYEE PROFILE, ASSIGNMENT HISTORY & DEPLOY TO PROJECT -->
    <asp:Panel ID="pnlEmployeeProfile" runat="server" Visible="false" CssClass="card shadow-sm border-info mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <h5 class="m-0"><i class="bi bi-person-vcard me-1"></i> Employee Profile &amp; Deployment History</h5>
            <asp:Button ID="btnCloseProfile" runat="server" Text="Close" CssClass="btn btn-sm btn-light" OnClick="btnCloseProfile_Click" CausesValidation="false" />
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-6">
                    <p class="mb-1"><strong>Name:</strong> <asp:Label ID="lblProfName" runat="server" /></p>
                    <p class="mb-1"><strong>TRN:</strong> <asp:Label ID="lblProfTRN" runat="server" /></p>
                    <p class="mb-1"><strong>Job Title:</strong> <asp:Label ID="lblProfJob" runat="server" /></p>
                    <p class="mb-1"><strong>Address:</strong> <asp:Label ID="lblProfAddress" runat="server" /></p>
                </div>
                <div class="col-md-6">
                    <h6 class="fw-bold text-brand-olive">Add Skill</h6>
                    <div class="input-group input-group-sm mb-2">
                        <asp:TextBox ID="txtNewSkill" runat="server" CssClass="form-control" placeholder="e.g. AutoCAD" />
                        <asp:Button ID="btnAddSkill" runat="server" Text="Add Skill" CssClass="btn btn-brand-olive" OnClick="btnAddSkill_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>

            <h6 class="fw-bold text-brand-ocean">Assignment History &amp; Earnings (FN_EmployeeAssignmentCost)</h6>
            <asp:GridView ID="gvEmpAssignments" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered table-sm mb-3">
                <Columns>
                    <asp:BoundField DataField="ProjectCode" HeaderText="Code" />
                    <asp:BoundField DataField="ProjectName" HeaderText="Project" />
                    <asp:BoundField DataField="ProjectRole" HeaderText="Role" />
                    <asp:BoundField DataField="StartDate" HeaderText="Start" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="EndDate" HeaderText="End" DataFormatString="{0:yyyy-MM-dd}" NullDisplayText="Active" />
                    <asp:BoundField DataField="PayRate" HeaderText="Daily Rate" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="TotalEarned" HeaderText="Assignment Cost" DataFormatString="{0:C}" />
                </Columns>
            </asp:GridView>

            <!-- DEPLOY TO PROJECT (TR_AssignEmployeeWithValidation) -->
            <div class="border-top pt-3">
                <h6 class="fw-bold text-brand-gold">Deploy Employee to Project</h6>
                <div class="row g-2">
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlDeployProject" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                    </div>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtDeployRole" runat="server" CssClass="form-control form-control-sm" placeholder="Role" />
                    </div>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtDeployRate" runat="server" CssClass="form-control form-control-sm" placeholder="Pay Rate" />
                    </div>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtDeployStart" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                    </div>
                    <div class="col-md-2">
                        <asp:DropDownList ID="ddlDeployForeman" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                    </div>
                    <div class="col-md-1 d-grid">
                        <asp:Button ID="btnDeployEmp" runat="server" Text="Deploy" CssClass="btn btn-sm btn-brand-gold" OnClick="btnDeployEmp_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- ADD / EDIT EMPLOYEE FORM (HR_Admin / SystemAdmin) -->
    <asp:Panel ID="pnlEmployeeForm" runat="server" CssClass="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <asp:Label ID="lblEmpFormTitle" runat="server" Text="<i class='bi bi-person-plus-fill'></i> Register New Employee"></asp:Label>
        </div>
        <div class="card-body">
            <asp:HiddenField ID="hfEditEmpID" runat="server" Value="0" />
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label fw-bold">Department *</label>
                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">TRN (9 Digits) *</label>
                    <asp:TextBox ID="txtTRN" runat="server" MaxLength="9" CssClass="form-control" placeholder="123456789" />
                    <asp:RequiredFieldValidator ID="rfvTRN" runat="server" ControlToValidate="txtTRN" ErrorMessage="9-digit TRN required." CssClass="text-danger small" ValidationGroup="EmpGroup" Display="Dynamic" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Job Type *</label>
                    <asp:TextBox ID="txtJobType" runat="server" CssClass="form-control" placeholder="e.g. Civil Engineer" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">First Name *</label>
                    <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Last Name *</label>
                    <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Date Hired</label>
                    <asp:TextBox ID="txtDateHired" runat="server" TextMode="Date" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Street Address *</label>
                    <asp:TextBox ID="txtStreet" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">City *</label>
                    <asp:TextBox ID="txtCity" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Parish *</label>
                    <asp:TextBox ID="txtParish" runat="server" CssClass="form-control" />
                </div>
            </div>
            <div class="mt-3 text-end">
                <asp:Button ID="btnCancelEmp" runat="server" Text="Cancel" CssClass="btn btn-secondary me-2" Visible="false" OnClick="btnCancelEmp_Click" CausesValidation="false" />
                <asp:Button ID="btnSaveEmp" runat="server" Text="Save Employee" CssClass="btn btn-brand-ocean" ValidationGroup="EmpGroup" OnClick="btnSaveEmp_Click" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>