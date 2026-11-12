<%@ Page Title="Client Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Client.aspx.cs" Inherits="Promaneng_Company_Portal.Client" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- TOP QUICK ACTIONS -->
    <asp:Panel ID="pnlTopActions" runat="server" CssClass="card bg-light shadow-sm mb-4">
        <div class="card-body d-flex justify-content-between align-items-center py-2">
            <span class="fw-bold text-secondary"><i class="bi bi-speedometer2"></i> Quick Actions:</span>
            <div>
                <a href="#addClientSection" class="btn btn-sm btn-Add-New-Client me-2">
                    <i class="bi bi-person-plus-fill"></i> Add New Client
                </a>
            </div>
        </div>
    </asp:Panel>

    <asp:Label ID="lblStatusMessage" runat="server" EnableViewState="false"></asp:Label>

    <!-- CLIENT DIRECTORY -->
    <div class="card shadow-sm mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <span class="fw-bold"><i class="bi bi-people-fill"></i> All Clients</span>
            <span class="badge count-badges"><asp:Label ID="lblActiveCount" runat="server">0</asp:Label> Total</span>
        </div>

        <div class="card-body p-0">
            <asp:GridView ID="gvClients" runat="server" AutoGenerateColumns="False" DataKeyNames="ClientID"
                CssClass="table table-striped table-hover m-0 align-middle" OnRowCommand="gvClients_RowCommand">
                <Columns>
                    <asp:BoundField DataField="ClientID" HeaderText="ID" ReadOnly="True" />
                    <asp:TemplateField HeaderText="Client Name">
                        <ItemTemplate>
                            <%# Eval("FirstName") %> <%# Eval("LastName") %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="PhoneNumber" HeaderText="Phone" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:TemplateField HeaderText="Address">
                        <ItemTemplate>
                            <%# Eval("StreetAddress") %>, <%# Eval("City") %>, <%# Eval("Parish") %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnViewProfile" runat="server" CommandName="ViewProfile" CommandArgument='<%# Eval("ClientID") %>' CssClass="btn btn-sm btn-View-Profile me-1">
                                <i class="bi bi-eye-fill"></i> Profile
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditClient" CommandArgument='<%# Eval("ClientID") %>' CssClass="btn btn-sm btn-Edit-Client me-1">
                                <i class="bi bi-pencil-square"></i> Edit
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="p-3 text-center text-muted">No clients found in the database.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>

    <!-- CLIENT PROFILE & FINANCIAL TRANSPARENCY -->
    <asp:Panel ID="pnlClientProfile" runat="server" Visible="false" CssClass="card shadow-sm border-info mb-4">
        <div class="card-header card-header-all d-flex justify-content-between align-items-center">
            <h5 class="m-0"><i class="bi bi-person-lines-fill"></i> Client Profile &amp; Commissioned Projects</h5>
            <div>
                <asp:HyperLink ID="hlCreateProjectForClient" runat="server" CssClass="btn btn-sm btn-brand-gold me-2">
                    <i class="bi bi-plus-circle me-1"></i> Create Project for Client
                </asp:HyperLink>
                <asp:Button ID="btnCloseProfile" runat="server" Text="Close" CssClass="btn btn-sm btn-light" OnClick="btnCloseProfile_Click" CausesValidation="false" />
            </div>
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-6">
                    <h6 class="fw-bold text-brand-olive">Contact Details</h6>
                    <p class="mb-1"><strong>Name:</strong> <asp:Label ID="lblProfName" runat="server"></asp:Label></p>
                    <p class="mb-1"><strong>Phone:</strong> <asp:Label ID="lblProfPhone" runat="server"></asp:Label></p>
                    <p class="mb-1"><strong>Email:</strong> <asp:Label ID="lblProfEmail" runat="server"></asp:Label></p>
                    <p class="mb-1"><strong>Address:</strong> <asp:Label ID="lblProfAddress" runat="server"></asp:Label></p>
                </div>
            </div>
            <h6 class="fw-bold text-brand-ocean">Commissioned Projects &amp; Financial Spend</h6>
            <asp:GridView ID="gvClientProjects" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered table-sm m-0">
                <Columns>
                    <asp:BoundField DataField="ProjectCode" HeaderText="Code" />
                    <asp:BoundField DataField="ProjectName" HeaderText="Project Name" />
                    <asp:BoundField DataField="Status" HeaderText="Status" />
                    <asp:BoundField DataField="EstimatedCost" HeaderText="Est. Budget" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="TotalLaborCost" HeaderText="Labor Cost" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="TotalEquipmentCost" HeaderText="Equipment Cost" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="TotalExpenses" HeaderText="Total Spent" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="BudgetStatus" HeaderText="Budget Health" />
                </Columns>
                <EmptyDataTemplate>
                    <div class="p-2 text-muted small">No projects commissioned by this client.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </asp:Panel>

    <!-- ADD / EDIT CLIENT FORM -->
    <asp:Panel ID="pnlClientForm" runat="server">
        <div id="addClientSection" class="card shadow-sm mb-4">
            <div class="card-header card-header-all fw-bold">
                <asp:Label ID="lblFormTitle" runat="server" Text="<i class='bi bi-person-plus-fill'></i> Add New Client"></asp:Label>
            </div>
            <div class="card-body">
                <asp:HiddenField ID="hfEditClientID" runat="server" Value="0" />
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">First Name *</label>
                        <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" />
                        <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName" ErrorMessage="First name required." CssClass="text-danger small" ValidationGroup="ClientFormGroup" Display="Dynamic" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Last Name *</label>
                        <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" />
                        <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName" ErrorMessage="Last name required." CssClass="text-danger small" ValidationGroup="ClientFormGroup" Display="Dynamic" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Email Address *</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="user@example.com" />
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email required." CssClass="text-danger small" ValidationGroup="ClientFormGroup" Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$" ErrorMessage="Invalid email format." CssClass="text-danger small" ValidationGroup="ClientFormGroup" Display="Dynamic" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Phone Number * (876-XXX-XXXX)</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="876-927-1000" />
                        <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Phone required." CssClass="text-danger small" ValidationGroup="ClientFormGroup" Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone" ValidationExpression="^\d{3}-\d{3}-\d{4}$" ErrorMessage="Use 876-XXX-XXXX format." CssClass="text-danger small" ValidationGroup="ClientFormGroup" Display="Dynamic" />
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
                        <asp:TextBox ID="txtParish" runat="server" CssClass="form-control" placeholder="e.g. St. Andrew" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Country</label>
                        <asp:TextBox ID="txtCountry" runat="server" CssClass="form-control" Text="Jamaica" />
                    </div>
                </div>
                <div class="mt-3 text-end">
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary me-2" OnClick="btnCancelEdit_Click" CausesValidation="false" Visible="false" />
                    <asp:Button ID="btnSaveClient" runat="server" Text="Save Client" CssClass="btn btn-brand-ocean" ValidationGroup="ClientFormGroup" OnClick="btnSaveClient_Click" />
                </div>
            </div>
        </div>
    </asp:Panel>

</asp:Content>