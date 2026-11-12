<%@ Page Title="Vendor & Maintenance Logs" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Maintenance.aspx.cs" Inherits="Promaneng_Company_Portal.Maintenance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <!-- VENDOR DIRECTORY & PERFORMANCE (vw_VendorPerformanceAndSpend) -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <i class="bi bi-building-check me-1"></i> Approved Vendors &amp; Maintenance Performance
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvVendors" runat="server" AutoGenerateColumns="False" CssClass="table table-striped table-hover m-0 align-middle">
                <Columns>
                    <asp:BoundField DataField="VendorID" HeaderText="ID" />
                    <asp:BoundField DataField="CompanyName" HeaderText="Company Name" />
                    <asp:BoundField DataField="LiaisonName" HeaderText="Liaison" />
                    <asp:BoundField DataField="LiaisonPhone" HeaderText="Phone" />
                    <asp:BoundField DataField="LiaisonEmail" HeaderText="Email" />
                    <asp:BoundField DataField="TotalMaintenanceJobs" HeaderText="Jobs" />
                    <asp:BoundField DataField="AverageMaintenanceDurationDays" HeaderText="Avg Days" NullDisplayText="N/A" />
                    <asp:BoundField DataField="TotalMaintenanceSpend" HeaderText="Total Spend" DataFormatString="{0:C}" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- SEND EQUIPMENT TO MAINTENANCE (TR_EquipmentMaintenanceWorkflow) -->
    <asp:Panel ID="pnlNewServiceOrder" runat="server" CssClass="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <i class="bi bi-wrench-adjustable-circle me-1"></i> Send Equipment to Maintenance
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label fw-bold">Equipment *</label>
                    <asp:DropDownList ID="ddlEquipment" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Repair Vendor *</label>
                    <asp:DropDownList ID="ddlVendor" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Service Start Date *</label>
                    <asp:TextBox ID="txtServiceStart" runat="server" TextMode="Date" CssClass="form-control" />
                </div>
                <div class="col-md-12">
                    <label class="form-label fw-bold">Fault / Service Description *</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" placeholder="Describe mechanical fault or scheduled service..." />
                </div>
            </div>
            <div class="mt-3 text-end">
                <asp:Button ID="btnSubmitMaintenance" runat="server" Text="Dispatch to Vendor" CssClass="btn btn-brand-gold" OnClick="btnSubmitMaintenance_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- MAINTENANCE RECORDS & COMPLETE MAINTENANCE (Fires trg_ReturnEquipmentAfterMaintenance) -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <i class="bi bi-tools me-1"></i> Maintenance Logs &amp; Service Completion
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvMaintenanceRecords" runat="server" AutoGenerateColumns="False" CssClass="table table-striped table-hover m-0 align-middle" OnRowCommand="gvMaintenanceRecords_RowCommand">
                <Columns>
                    <asp:BoundField DataField="VendorID" HeaderText="Vendor ID" />
                    <asp:BoundField DataField="CompanyName" HeaderText="Vendor" />
                    <asp:BoundField DataField="EquipmentID" HeaderText="Eq ID" />
                    <asp:BoundField DataField="EquipmentName" HeaderText="Equipment" />
                    <asp:BoundField DataField="StartDate" HeaderText="Start Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="EndDate" HeaderText="End Date" DataFormatString="{0:yyyy-MM-dd}" NullDisplayText="In Progress" />
                    <asp:BoundField DataField="Description" HeaderText="Description" />
                    <asp:BoundField DataField="TotalCost" HeaderText="Cost" DataFormatString="{0:C}" />
                    <asp:TemplateField HeaderText="Complete Service">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnSelectComplete" runat="server" CommandName="SelectRecord"
                                CommandArgument='<%# Eval("VendorID") + "|" + Eval("EquipmentID") + "|" + Convert.ToDateTime(Eval("StartDate")).ToString("yyyy-MM-dd") %>'
                                Visible='<%# Eval("EndDate") == DBNull.Value %>'
                                CssClass="btn btn-sm btn-brand-olive">
                                Complete Repair
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <!-- COMPLETE MAINTENANCE PANEL -->
        <asp:Panel ID="pnlCompleteRepair" runat="server" Visible="false" CssClass="card-footer bg-light">
            <h6 class="fw-bold text-brand-olive">Finalize Maintenance &amp; Return Equipment to Available</h6>
            <asp:HiddenField ID="hfCompleteKey" runat="server" />
            <div class="row g-2 align-items-end">
                <div class="col-md-4">
                    <label class="form-label small fw-bold">Completion Date</label>
                    <asp:TextBox ID="txtCompleteEndDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                </div>
                <div class="col-md-4">
                    <label class="form-label small fw-bold">Final Repair Cost (JMD)</label>
                    <asp:TextBox ID="txtFinalCost" runat="server" CssClass="form-control form-control-sm" placeholder="4500.00" />
                </div>
                <div class="col-md-4">
                    <asp:Button ID="btnConfirmComplete" runat="server" Text="Save & Flip Equipment to Available" CssClass="btn btn-sm btn-brand-olive" OnClick="btnConfirmComplete_Click" />
                </div>
            </div>
        </asp:Panel>
    </div>

    <!-- ADD VENDOR FORM -->
    <asp:Panel ID="pnlAddVendor" runat="server" CssClass="card shadow-sm mb-4">
        <div class="card-header card-header-all fw-bold">
            <i class="bi bi-plus-circle me-1"></i> Register New Repair Vendor
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label fw-bold">Company Name *</label>
                    <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-bold">Liaison Name</label>
                    <asp:TextBox ID="txtLiaisonName" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-bold">Liaison Email</label>
                    <asp:TextBox ID="txtLiaisonEmail" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-bold">Liaison Phone (876-XXX-XXXX)</label>
                    <asp:TextBox ID="txtLiaisonPhone" runat="server" CssClass="form-control" />
                </div>
            </div>
            <div class="mt-3 text-end">
                <asp:Button ID="btnAddVendor" runat="server" Text="Add Vendor" CssClass="btn btn-brand-ocean" OnClick="btnAddVendor_Click" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>