<%@ Page Title="Project Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProjectProfile.aspx.cs" Inherits="Promaneng_Company_Portal.ProjectProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <!-- HEADER & CLOSE PROJECT WORKFLOW -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <h5 class="m-0"><i class="bi bi-diagram-3-fill me-1"></i> <asp:Label ID="lblProjectTitle" runat="server"></asp:Label></h5>
            <div>
                <a href="Projects.aspx" class="btn btn-sm btn-light me-2">&larr; Back to Projects</a>
            </div>
        </div>
        <div class="card-body">
            <div class="row g-3 mb-3">
                <div class="col-md-4"><strong>Client:</strong> <asp:Label ID="lblClientName" runat="server" /></div>
                <div class="col-md-4"><strong>Status:</strong> <asp:Label ID="lblStatus" runat="server" CssClass="fw-bold" /></div>
                <div class="col-md-4"><strong>Location:</strong> <asp:Label ID="lblLocation" runat="server" /></div>
                <div class="col-md-3"><strong>Estimated Budget:</strong> <asp:Label ID="lblEstCost" runat="server" /></div>
                <div class="col-md-3"><strong>Labor Cost:</strong> <asp:Label ID="lblLaborCost" runat="server" /></div>
                <div class="col-md-3"><strong>Equipment Cost:</strong> <asp:Label ID="lblEquipCost" runat="server" /></div>
                <div class="col-md-3"><strong>Budget Health:</strong> <asp:Label ID="lblBudgetHealth" runat="server" CssClass="fw-bold" /></div>
            </div>

            <!-- FORMALLY CLOSE PROJECT (sp_CloseProject) -->
            <asp:Panel ID="pnlCloseProject" runat="server" CssClass="border-top pt-3 mt-2">
                <div class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Completion Date (Close Project)</label>
                        <asp:TextBox ID="txtCompletionDate" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                    <div class="col-md-4">
                        <asp:Button ID="btnCloseProject" runat="server" Text="Formally Close Project" CssClass="btn btn-brand-gold" OnClick="btnCloseProject_Click" />
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <!-- ASSIGNED EMPLOYEES (FN_EmployeeAssignmentCost + TR_AssignEmployeeWithValidation) -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <i class="bi bi-people-fill me-1"></i> Assigned Crew &amp; Labor Costs
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvProjectCrew" runat="server" AutoGenerateColumns="False" CssClass="table table-striped m-0 align-middle">
                <Columns>
                    <asp:BoundField DataField="EmployeeID" HeaderText="Emp ID" />
                    <asp:BoundField DataField="EmployeeName" HeaderText="Employee" />
                    <asp:BoundField DataField="ProjectRole" HeaderText="Role" />
                    <asp:BoundField DataField="StartDate" HeaderText="Start Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="EndDate" HeaderText="End Date" DataFormatString="{0:yyyy-MM-dd}" NullDisplayText="Active" />
                    <asp:BoundField DataField="PayRate" HeaderText="Daily Rate" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="AssignmentCost" HeaderText="Total Labor Cost" DataFormatString="{0:C}" />
                </Columns>
                <EmptyDataTemplate>
                    <div class="p-3 text-muted">No crew members assigned to this project yet.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>

        <!-- ADD TEAM MEMBER FORM -->
        <asp:Panel ID="pnlAddCrew" runat="server" CssClass="card-footer bg-light">
            <h6 class="fw-bold text-brand-ocean mb-2">Add Team Member to Project</h6>
            <div class="row g-2">
                <div class="col-md-3">
                    <asp:DropDownList ID="ddlEmployee" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <asp:TextBox ID="txtRole" runat="server" CssClass="form-control form-control-sm" placeholder="Project Role" />
                </div>
                <div class="col-md-2">
                    <asp:TextBox ID="txtPayRate" runat="server" CssClass="form-control form-control-sm" placeholder="Daily Pay Rate" />
                </div>
                <div class="col-md-2">
                    <asp:TextBox ID="txtAssignStart" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                </div>
                <div class="col-md-2">
                    <asp:DropDownList ID="ddlForeman" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                </div>
                <div class="col-md-1 d-grid">
                    <asp:Button ID="btnAssignCrew" runat="server" Text="Assign" CssClass="btn btn-sm btn-brand-olive" OnClick="btnAssignCrew_Click" />
                </div>
            </div>
        </asp:Panel>
    </div>

    <!-- ASSIGNED EQUIPMENT (vw_EquipmentUsageCosts + sp_CheckinEquipment) -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <i class="bi bi-truck me-1"></i> Deployed Equipment &amp; Check-In
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvProjectEquipment" runat="server" AutoGenerateColumns="False" CssClass="table table-striped m-0 align-middle" OnRowCommand="gvProjectEquipment_RowCommand">
                <Columns>
                    <asp:BoundField DataField="EquipmentID" HeaderText="Eq ID" />
                    <asp:BoundField DataField="EquipmentName" HeaderText="Equipment" />
                    <asp:BoundField DataField="EquipmentType" HeaderText="Category" />
                    <asp:BoundField DataField="StartDate" HeaderText="Deployed On" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="EndDate" HeaderText="Returned On" DataFormatString="{0:yyyy-MM-dd}" NullDisplayText="In Use" />
                    <asp:BoundField DataField="TotalCost" HeaderText="Usage Cost" DataFormatString="{0:C}" NullDisplayText="Ongoing" />
                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnCheckinEq" runat="server" CommandName="CheckinEquipment"
                                CommandArgument='<%# Eval("EquipmentID") %>'
                                Visible='<%# Eval("EndDate") == DBNull.Value %>'
                                CssClass="btn btn-sm btn-brand-ocean">
                                Return Today
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="p-3 text-muted">No equipment deployed to this project.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>

</asp:Content>