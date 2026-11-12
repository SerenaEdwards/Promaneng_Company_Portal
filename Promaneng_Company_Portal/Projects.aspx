<%@ Page Title="Project Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Projects.aspx.cs" Inherits="Promaneng_Company_Portal.Projects" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <!-- BUDGET HEALTH SUMMARY CARDS (vw_ProjectFinancialOverview) -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="stat-card olive-border shadow-sm">
                <span class="text-muted small text-uppercase fw-semibold d-block mb-1">Within Budget</span>
                <h2 class="fw-bold m-0 text-brand-olive"><asp:Label ID="lblWithinBudgetCount" runat="server" Text="0"></asp:Label></h2>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card gold-border shadow-sm">
                <span class="text-muted small text-uppercase fw-semibold d-block mb-1">Near Budget Limit (&ge;90%)</span>
                <h2 class="fw-bold m-0 text-brand-gold"><asp:Label ID="lblNearBudgetCount" runat="server" Text="0"></asp:Label></h2>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card dark-border shadow-sm">
                <span class="text-muted small text-uppercase fw-semibold d-block mb-1">Over Budget</span>
                <h2 class="fw-bold m-0 text-danger"><asp:Label ID="lblOverBudgetCount" runat="server" Text="0"></asp:Label></h2>
            </div>
        </div>
    </div>

    <!-- ACTIVE PROJECTS SUMMARY (vw_ActiveProjectSummary) -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <span class="fw-bold"><i class="bi bi-lightning-fill me-1"></i> Active Projects (Not Started &amp; Ongoing)</span>
            <span class="badge count-badges"><asp:Label ID="lblActiveSummaryCount" runat="server">0</asp:Label> Active</span>
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvActiveProjects" runat="server" AutoGenerateColumns="False" CssClass="table table-striped table-hover m-0 align-middle" OnRowCommand="gvProjects_RowCommand">
                <Columns>
                    <asp:BoundField DataField="ProjectCode" HeaderText="Code" />
                    <asp:BoundField DataField="ProjectName" HeaderText="Project Name" />
                    <asp:BoundField DataField="ClientName" HeaderText="Client" />
                    <asp:BoundField DataField="Status" HeaderText="Status" />
                    <asp:BoundField DataField="EstimatedCost" HeaderText="Estimated Budget" DataFormatString="{0:C}" />
                    <asp:TemplateField HeaderText="Est. Duration">
                        <ItemTemplate><%# FormatDuration(Eval("EstimatedTime")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnViewActive" runat="server" CommandName="ViewProject" CommandArgument='<%# Eval("ProjectCode") %>' CssClass="btn btn-sm btn-View-Profile me-1">
                                <i class="bi bi-eye-fill"></i> Profile
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- ALL PROJECTS & FINANCIAL OVERVIEW (vw_ProjectFinancialOverview) -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <span class="fw-bold"><i class="bi bi-diagram-3-fill me-1"></i> All Projects &amp; Financial Health</span>
            <span class="badge count-badges"><asp:Label ID="lblActiveCount" runat="server">0</asp:Label> Total</span>
        </div>

        <div class="card-body p-0">
            <asp:GridView ID="gvProjects" runat="server" AutoGenerateColumns="False" DataKeyNames="ProjectCode"
                CssClass="table table-striped table-hover m-0 align-middle" OnRowCommand="gvProjects_RowCommand">
                <Columns>
                    <asp:BoundField DataField="ProjectCode" HeaderText="ID" ReadOnly="True" />
                    <asp:BoundField DataField="ProjectName" HeaderText="Project Name" ReadOnly="True" />
                    <asp:BoundField DataField="ClientName" HeaderText="Client" ReadOnly="True" />
                    <asp:BoundField DataField="Status" HeaderText="Status" ReadOnly="True" />
                    <asp:BoundField DataField="EstimatedCost" HeaderText="Est. Budget" DataFormatString="{0:C}" ReadOnly="True" />
                    <asp:BoundField DataField="TotalLaborCost" HeaderText="Labor Cost" DataFormatString="{0:C}" ReadOnly="True" />
                    <asp:BoundField DataField="TotalEquipmentCost" HeaderText="Equipment Cost" DataFormatString="{0:C}" ReadOnly="True" />
                    <asp:BoundField DataField="RemainingBudget" HeaderText="Remaining" DataFormatString="{0:C}" ReadOnly="True" />
                    <asp:BoundField DataField="BudgetStatus" HeaderText="Budget Status" ReadOnly="True" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnViewProfile" runat="server" CommandName="ViewProject" CommandArgument='<%# Eval("ProjectCode") %>' CssClass="btn btn-sm btn-View-Profile me-1">
                                <i class="bi bi-eye-fill"></i> Profile
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditProject" CommandArgument='<%# Eval("ProjectCode") %>' CssClass="btn btn-sm btn-Edit-Project me-1">
                                <i class="bi bi-pencil-square"></i> Edit
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="p-3 text-center text-muted">No projects found in the database.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>

    <!-- ADD NEW PROJECT FORM (sp_RegisterNewProject) -->
    <asp:Panel ID="pnlAddProject" runat="server">
        <div id="addProjectSection" class="card shadow-sm mb-4">
            <div class="card-header card-header-all fw-bold">
                <i class="bi bi-folder-plus me-1"></i> Register New Engineering Project
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Client *</label>
                        <asp:DropDownList ID="ddlClient" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Project Name *</label>
                        <asp:TextBox ID="txtProjectName" runat="server" CssClass="form-control" />
                        <asp:RequiredFieldValidator ID="rfvProjName" runat="server" ControlToValidate="txtProjectName" ErrorMessage="Project name required." CssClass="text-danger small" ValidationGroup="ProjGroup" Display="Dynamic" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Estimated Cost (JMD) *</label>
                        <asp:TextBox ID="txtEstCost" runat="server" CssClass="form-control" placeholder="15000000.00" />
                        <asp:RequiredFieldValidator ID="rfvEstCost" runat="server" ControlToValidate="txtEstCost" ErrorMessage="Estimated cost required." CssClass="text-danger small" ValidationGroup="ProjGroup" Display="Dynamic" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Estimated Duration (Days) *</label>
                        <asp:TextBox ID="txtEstTime" runat="server" CssClass="form-control" placeholder="180" />
                        <asp:RequiredFieldValidator ID="rfvEstTime" runat="server" ControlToValidate="txtEstTime" ErrorMessage="Estimated time required." CssClass="text-danger small" ValidationGroup="ProjGroup" Display="Dynamic" />
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Site Street Address</label>
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
                        <asp:TextBox ID="txtCountry" runat="server" CssClass="form-control" Text="Jamaica" />
                    </div>
                </div>
                <div class="mt-3 text-end">
                    <asp:Button ID="btnRegisterProject" runat="server" Text="Create Project" CssClass="btn btn-brand-gold" ValidationGroup="ProjGroup" OnClick="btnRegisterProject_Click" />
                </div>
            </div>
        </div>
    </asp:Panel>

</asp:Content>