<%@ Page Title="Resource Assignments" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Assignments.aspx.cs" Inherits="Promaneng_Company_Portal.Assignments" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <!-- ALLOCATION WORKFLOWS -->
    <div class="row g-4 mb-4">
        <!-- EMPLOYEE ASSIGNMENT FORM (TR_AssignEmployeeWithValidation) -->
        <div id="employeeAssignSection" class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-header card-header-all fw-bold">
                    <i class="bi bi-person-check-fill me-1"></i> Assign Employee to Project
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Employee *</label>
                            <asp:DropDownList ID="ddlEmployee" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Target Project *</label>
                            <asp:DropDownList ID="ddlProject" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Project Role *</label>
                            <asp:TextBox ID="txtProjectRole" runat="server" CssClass="form-control" placeholder="e.g. Site Engineer" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Daily Pay Rate *</label>
                            <asp:TextBox ID="txtPayRate" runat="server" CssClass="form-control" placeholder="6500.00" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Start Date *</label>
                            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">End Date (Optional)</label>
                            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Supervising Foreman *</label>
                            <asp:DropDownList ID="ddlForeman" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="mt-3 text-end">
                        <asp:Button ID="btnAssignEmployee" runat="server" Text="Assign Employee" CssClass="btn btn-brand-olive" OnClick="btnAssignEmployee_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- EQUIPMENT ASSIGNMENT & RETURN FORM (sp_CheckoutEquipment & sp_CheckinEquipment) -->
        <div id="equipmentAssignSection" class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-header card-header-all fw-bold">
                    <i class="bi bi-truck-flatbed me-1"></i> Dispatch / Return Machinery
                </div>
                <div class="card-body">
                    <h6 class="fw-bold text-brand-ocean">Checkout Equipment to Site</h6>
                    <div class="row g-2 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Project</label>
                            <asp:DropDownList ID="ddlEqProject" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Available Equipment</label>
                            <asp:DropDownList ID="ddlAvailableEquipment" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Supervisor</label>
                            <asp:DropDownList ID="ddlSupervisor" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Checkout Date</label>
                            <asp:TextBox ID="txtCheckoutDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                        </div>
                        <div class="col-12 text-end">
                            <asp:Button ID="btnCheckoutEq" runat="server" Text="Dispatch Machinery" CssClass="btn btn-sm btn-brand-gold" OnClick="btnCheckoutEq_Click" />
                        </div>
                    </div>

                    <hr />
                    <h6 class="fw-bold text-brand-olive">Check-In Active Machinery</h6>
                    <div class="row g-2 align-items-end">
                        <div class="col-md-7">
                            <label class="form-label small fw-bold">Active Deployment</label>
                            <asp:DropDownList ID="ddlActiveDeployments" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold">Return Date</label>
                            <asp:TextBox ID="txtReturnDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                        </div>
                        <div class="col-md-2 d-grid">
                            <asp:Button ID="btnCheckinEq" runat="server" Text="Return" CssClass="btn btn-sm btn-brand-ocean" OnClick="btnCheckinEq_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- READ-ONLY REFERENCE DIRECTORIES -->
    <h5 class="fw-bold text-brand-dark mb-3">Scheduling Reference Directories (Read-Only)</h5>
    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-brand-ocean fw-bold">Staff &amp; Skills</div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvRefEmployees" runat="server" AutoGenerateColumns="False" CssClass="table table-sm table-striped m-0">
                        <Columns>
                            <asp:BoundField DataField="EmployeeID" HeaderText="ID" />
                            <asp:BoundField DataField="FullName" HeaderText="Name" />
                            <asp:BoundField DataField="SkillSet" HeaderText="Skills" />
                            <asp:BoundField DataField="AvailabilityStatus" HeaderText="Status" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-brand-olive fw-bold">Active Projects</div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvRefProjects" runat="server" AutoGenerateColumns="False" CssClass="table table-sm table-striped m-0">
                        <Columns>
                            <asp:BoundField DataField="ProjectCode" HeaderText="Code" />
                            <asp:BoundField DataField="ProjectName" HeaderText="Project" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-brand-gold fw-bold">Fleet Status</div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvRefEquipment" runat="server" AutoGenerateColumns="False" CssClass="table table-sm table-striped m-0">
                        <Columns>
                            <asp:BoundField DataField="EquipmentID" HeaderText="ID" />
                            <asp:BoundField DataField="Name" HeaderText="Machine" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>