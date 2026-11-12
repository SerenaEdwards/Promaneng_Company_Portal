<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Promaneng_Company_Portal._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Welcome Header -->
    <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
        <div>
            <h3 class="fw-bold mb-1 text-brand-olive">Promaneng Operations</h3>
            <p class="text-muted m-0 small">Internal Management &amp; Project Portal</p>
        </div>
        <div>
            <span class="badge bg-light text-dark border px-3 py-2 fw-normal">
                Status: <strong class="text-brand-olive">Online</strong>
            </span>
        </div>
    </div>

    <!-- Active Operations Summary Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="stat-card gold-border shadow-sm">
                <span class="text-muted small text-uppercase fw-semibold d-block mb-1">Active Projects</span>
                <div class="d-flex justify-content-between align-items-center">
                    <h2 class="fw-bold m-0 text-brand-gold"><asp:Label ID="lblActiveProjectsCount" runat="server" Text="0"></asp:Label></h2>
                    <i class="bi bi-diagram-3 fs-3 text-muted opacity-50"></i>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card olive-border shadow-sm">
                <span class="text-muted small text-uppercase fw-semibold d-block mb-1">Available Equipment</span>
                <div class="d-flex justify-content-between align-items-center">
                    <h2 class="fw-bold m-0 text-brand-olive"><asp:Label ID="lblAvailableEquipmentCount" runat="server" Text="0"></asp:Label></h2>
                    <i class="bi bi-truck fs-3 text-muted opacity-50"></i>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card ocean-border shadow-sm">
                <span class="text-muted small text-uppercase fw-semibold d-block mb-1">Employees Assigned</span>
                <div class="d-flex justify-content-between align-items-center">
                    <h2 class="fw-bold m-0 text-brand-ocean"><asp:Label ID="lblAssignedEmployeesCount" runat="server" Text="0"></asp:Label></h2>
                    <i class="bi bi-person-badge fs-3 text-muted opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Links to Primary Workflows -->
    <div class="card bg-light shadow-sm mb-4">
        <div class="card-body d-flex flex-wrap justify-content-between align-items-center gap-2 py-2">
            <span class="fw-bold text-secondary"><i class="bi bi-lightning-charge-fill text-brand-gold"></i> Primary Workflows:</span>
            <div class="d-flex flex-wrap gap-2">
                <a href="Client.aspx#addClientSection" class="btn btn-sm btn-brand-olive"><i class="bi bi-person-plus-fill me-1"></i> Register Client</a>
                <a href="Assignments.aspx#employeeAssignSection" class="btn btn-sm btn-brand-ocean"><i class="bi bi-person-check-fill me-1"></i> Assign Employee</a>
                <a href="Assignments.aspx#equipmentAssignSection" class="btn btn-sm btn-brand-gold"><i class="bi bi-truck-flatbed me-1"></i> Book Equipment</a>
            </div>
        </div>
    </div>

    <!-- High-Priority Alerts & Active Operations -->
    <div class="row g-4">
        <!-- Active Operations Table -->
        <div class="col-lg-7">
            <div class="card shadow-sm h-100">
                <div class="card-header card-header-all d-flex justify-content-between align-items-center">
                    <span class="fw-bold"><i class="bi bi-kanban me-1"></i> Active Projects &amp; Clients</span>
                    <a href="Projects.aspx" class="btn btn-sm btn-light">View All</a>
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvActiveOperations" runat="server" AutoGenerateColumns="False" CssClass="table table-striped table-hover m-0 align-middle">
                        <Columns>
                            <asp:BoundField DataField="ProjectCode" HeaderText="Code" />
                            <asp:BoundField DataField="ProjectName" HeaderText="Project" />
                            <asp:BoundField DataField="ClientName" HeaderText="Client" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                            <asp:BoundField DataField="EstimatedCost" HeaderText="Est. Budget" DataFormatString="{0:C}" />
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-3 text-center text-muted">No active projects currently running.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- High-Priority Alerts -->
        <div class="col-lg-5">
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-warning text-dark fw-bold">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i> Equipment Under Maintenance
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvMaintenanceAlerts" runat="server" AutoGenerateColumns="False" CssClass="table table-sm m-0 align-middle">
                        <Columns>
                            <asp:BoundField DataField="EquipmentID" HeaderText="ID" />
                            <asp:BoundField DataField="Name" HeaderText="Equipment" />
                            <asp:BoundField DataField="Type" HeaderText="Category" />
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-3 text-muted small">All fleet units are operational.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <div class="card shadow-sm">
                <div class="card-header bg-danger text-white fw-bold">
                    <i class="bi bi-clock-history me-1"></i> Schedule Overrun Alerts
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvScheduleAlerts" runat="server" AutoGenerateColumns="False" CssClass="table table-sm m-0 align-middle">
                        <Columns>
                            <asp:BoundField DataField="ProjectCode" HeaderText="Code" />
                            <asp:BoundField DataField="Name" HeaderText="Project" />
                            <asp:BoundField DataField="EstimatedTime" HeaderText="Est. Days" />
                            <asp:BoundField DataField="ElapsedDays" HeaderText="Elapsed Days" />
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-3 text-muted small">No active projects exceeding estimated schedule.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>