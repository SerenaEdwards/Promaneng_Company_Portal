<%@ Page Title="Equipment Fleet" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Equipment.aspx.cs" Inherits="Promaneng_Company_Portal.Equipment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <!-- EQUIPMENT INVENTORY TABLE -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <span class="fw-bold"><i class="bi bi-truck me-1"></i> Equipment Fleet Inventory</span>
            <span class="badge count-badges"><asp:Label ID="lblFleetCount" runat="server">0</asp:Label> Units</span>
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvEquipment" runat="server" AutoGenerateColumns="False" CssClass="table table-striped table-hover m-0 align-middle" OnRowCommand="gvEquipment_RowCommand">
                <Columns>
                    <asp:BoundField DataField="EquipmentID" HeaderText="ID" />
                    <asp:BoundField DataField="Name" HeaderText="Machine Name" />
                    <asp:BoundField DataField="Type" HeaderText="Category" />
                    <asp:BoundField DataField="OwnershipType" HeaderText="Ownership" />
                    <asp:BoundField DataField="CostPerDay" HeaderText="Daily Rate" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="Status" HeaderText="Operational Status" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnProfile" runat="server" CommandName="ViewEquipment" CommandArgument='<%# Eval("EquipmentID") %>' CssClass="btn btn-sm btn-View-Profile me-1">
                                <i class="bi bi-eye-fill"></i> Profile &amp; Ops
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditEquipment" CommandArgument='<%# Eval("EquipmentID") %>' CssClass="btn btn-sm btn-Edit-Client">
                                <i class="bi bi-pencil-square"></i> Edit
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- EQUIPMENT PROFILE, DISPATCH/RETURN & MAINTENANCE WORKFLOW -->
    <asp:Panel ID="pnlEquipmentProfile" runat="server" Visible="false" CssClass="card shadow-sm border-info mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <h5 class="m-0"><i class="bi bi-gear-wide-connected me-1"></i> <asp:Label ID="lblEqProfileTitle" runat="server" /></h5>
            <asp:Button ID="btnCloseEqProfile" runat="server" Text="Close" CssClass="btn btn-sm btn-light" OnClick="btnCloseEqProfile_Click" CausesValidation="false" />
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-4"><strong>Category:</strong> <asp:Label ID="lblEqType" runat="server" /></div>
                <div class="col-md-4"><strong>Ownership:</strong> <asp:Label ID="lblEqOwner" runat="server" /></div>
                <div class="col-md-4"><strong>Status:</strong> <asp:Label ID="lblEqStatus" runat="server" CssClass="fw-bold" /></div>
                <div class="col-md-4"><strong>Acquisition Cost:</strong> <asp:Label ID="lblEqAcq" runat="server" /></div>
                <div class="col-md-4"><strong>Daily Rate:</strong> <asp:Label ID="lblEqRate" runat="server" /></div>
            </div>

            <!-- DISPATCH TO SITE (sp_CheckoutEquipment) -->
            <asp:Panel ID="pnlDispatch" runat="server" CssClass="border rounded p-3 bg-light mb-3">
                <h6 class="fw-bold text-brand-olive"><i class="bi bi-send-check me-1"></i> Dispatch Equipment to Site</h6>
                <div class="row g-2">
                    <div class="col-md-4">
                        <asp:DropDownList ID="ddlDispatchProject" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                    </div>
                    <div class="col-md-4">
                        <asp:DropDownList ID="ddlDispatchSupervisor" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                    </div>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtDispatchDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                    </div>
                    <div class="col-md-2 d-grid">
                        <asp:Button ID="btnDispatch" runat="server" Text="Dispatch" CssClass="btn btn-sm btn-brand-olive" OnClick="btnDispatch_Click" CausesValidation="false" />
                    </div>
                </div>
            </asp:Panel>

            <!-- SEND TO MAINTENANCE (vw_VendorPerformanceAndSpend + TR_EquipmentMaintenanceWorkflow) -->
            <asp:Panel ID="pnlSendMaintenance" runat="server" CssClass="border rounded p-3 bg-light mb-3">
                <h6 class="fw-bold text-brand-gold"><i class="bi bi-wrench-adjustable me-1"></i> Send Equipment to Maintenance</h6>
                <p class="small text-muted mb-2">Vendor Track Record Reference (vw_VendorPerformanceAndSpend):</p>
                <asp:GridView ID="gvVendorRef" runat="server" AutoGenerateColumns="False" CssClass="table table-sm table-bordered bg-white mb-3">
                    <Columns>
                        <asp:BoundField DataField="VendorID" HeaderText="ID" />
                        <asp:BoundField DataField="CompanyName" HeaderText="Vendor" />
                        <asp:BoundField DataField="TotalMaintenanceJobs" HeaderText="Jobs" />
                        <asp:BoundField DataField="AverageMaintenanceDurationDays" HeaderText="Avg Turnaround (Days)" />
                        <asp:BoundField DataField="TotalMaintenanceSpend" HeaderText="Total Spend" DataFormatString="{0:C}" />
                    </Columns>
                </asp:GridView>

                <div class="row g-2">
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlMaintVendor" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                    </div>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtMaintStart" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                    </div>
                    <div class="col-md-5">
                        <asp:TextBox ID="txtMaintDesc" runat="server" CssClass="form-control form-control-sm" placeholder="Fault description..." />
                    </div>
                    <div class="col-md-2 d-grid">
                        <asp:Button ID="btnSendMaint" runat="server" Text="Send to Repair" CssClass="btn btn-sm btn-brand-gold" OnClick="btnSendMaint_Click" CausesValidation="false" />
                    </div>
                </div>
            </asp:Panel>

            <!-- DEPLOYMENT HISTORY (vw_EquipmentUsageCosts + sp_CheckinEquipment) -->
            <h6 class="fw-bold text-brand-ocean">Deployment History</h6>
            <asp:GridView ID="gvEqHistory" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered table-sm m-0" OnRowCommand="gvEqHistory_RowCommand">
                <Columns>
                    <asp:BoundField DataField="ProjectCode" HeaderText="Project Code" />
                    <asp:BoundField DataField="StartDate" HeaderText="Start Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="EndDate" HeaderText="End Date" DataFormatString="{0:yyyy-MM-dd}" NullDisplayText="Active" />
                    <asp:BoundField DataField="TotalCost" HeaderText="Total Cost" DataFormatString="{0:C}" NullDisplayText="Ongoing" />
                    <asp:TemplateField HeaderText="Return">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnReturnEq" runat="server" CommandName="ReturnFromProject"
                                CommandArgument='<%# Eval("ProjectCode") %>'
                                Visible='<%# Eval("EndDate") == DBNull.Value %>'
                                CssClass="btn btn-sm btn-brand-ocean">
                                Return Equipment
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </asp:Panel>

    <!-- ADD / UPDATE EQUIPMENT FORM -->
    <asp:Panel ID="pnlEquipmentForm" runat="server" CssClass="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <asp:Label ID="lblEqFormTitle" runat="server" Text="<i class='bi bi-plus-circle'></i> Add Equipment to Fleet"></asp:Label>
        </div>
        <div class="card-body">
            <asp:HiddenField ID="hfEditEqID" runat="server" Value="0" />
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label fw-bold">Machine Name *</label>
                    <asp:TextBox ID="txtEqName" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Category / Type *</label>
                    <asp:TextBox ID="txtEqType" runat="server" CssClass="form-control" placeholder="Heavy Machinery, Earthmoving..." />
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Ownership Type *</label>
                    <asp:DropDownList ID="ddlOwnership" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Owned" Value="Owned" />
                        <asp:ListItem Text="Rented" Value="Rented" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Acquisition Cost (JMD)</label>
                    <asp:TextBox ID="txtAcqCost" runat="server" CssClass="form-control" Text="0.00" />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Daily Rate (CostPerDay) *</label>
                    <asp:TextBox ID="txtDailyRate" runat="server" CssClass="form-control" />
                </div>
            </div>
            <div class="mt-3 text-end">
                <asp:Button ID="btnCancelEq" runat="server" Text="Cancel" CssClass="btn btn-secondary me-2" Visible="false" OnClick="btnCancelEq_Click" CausesValidation="false" />
                <asp:Button ID="btnSaveEq" runat="server" Text="Save Equipment" CssClass="btn btn-brand-ocean" OnClick="btnSaveEq_Click" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>