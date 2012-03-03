<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: CreateContractWizard.jsp,v 1.30 2011/11/02 16:30:55 cmu Exp $
 * Description: CreateContractWizard
 * Revision:    $Revision: 1.30 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/02 16:30:55 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2004-2010, CRIXP Corp., Switzerland
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 *
 * * Neither the name of CRIXP Corp. nor the names of the contributors
 * to openCRX may be used to endorse or promote products derived
 * from this software without specific prior written permission
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * ------------------
 *
 * This product includes software developed by the Apache Software
 * Foundation (http://www.apache.org/).
 *
 * This product includes software developed by contributors to
 * openMDX (http://www.openmdx.org/)
 */
%><%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
org.opencrx.kernel.backend.Accounts,
org.opencrx.kernel.backend.Products,
org.opencrx.kernel.backend.Contracts,
org.openmdx.base.exception.*,
org.openmdx.base.text.conversion.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*
" %><%
	request.setCharacterEncoding("UTF-8");
	String servletPath = "." + request.getServletPath();
	String servletPathPrefix = servletPath.substring(0, servletPath.lastIndexOf("/") + 1);
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =  request.getParameter(Action.PARAMETER_REQUEST_ID);
	String objectXri = request.getParameter(Action.PARAMETER_OBJECTXRI);
	if(objectXri == null || app == null || viewsCache.getView(requestId) == null) {
		response.sendRedirect(
			request.getContextPath() + "/" + WebKeys.SERVLET_NAME
		);
		return;
	}
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	Texts_1_0 texts = app.getTexts();
	Codes codes = app.getCodes();
	String formName = "CreateContractForm";
	String wizardName = "CreateContractWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "Refresh";
	boolean actionOk = "OK".equals(command);
	boolean actionCancel = "Cancel".equals(command);
	boolean actionRefresh = "Refresh".equals(command);
	boolean actionCreateOpportunity = "CreateOpportunity".equals(command);
	boolean actionCreateQuote = "CreateQuote".equals(command);
	boolean actionCreateSalesOrder = "CreateSalesOrder".equals(command);
	boolean actionCreateInvoice = "CreateInvoice".equals(command);
	boolean actionAddPosition = "AddPosition".equals(command);
	boolean actionSetBillingAddress = false;
	boolean actionSetShippingAddress = false;
	// Set Billing/Shipping Address
	String addressXri = null;
	for(int i = 0; i < 100; i++) {
		actionSetBillingAddress = command.equals("SetBillingAddress." + i);
		actionSetShippingAddress = command.equals("SetShippingAddress." + i);
		if(actionSetBillingAddress || actionSetShippingAddress) {
		    addressXri = request.getParameter("addressXri." + i);
		    break;
		}
	}
	// Delete position
	boolean actionDeletePosition = false;
	int deletePositionIndex = 0;
	for(int i = 0; i < 100; i++) {
	    actionDeletePosition = command.equals("DeletePosition." + i);
	    if(actionDeletePosition) {
	        deletePositionIndex = i;
	        break;
	    }
	}
	int contractPositionCount = request.getParameter("ContractPosition.Count") == null ?
	    0 :
	    Integer.valueOf(request.getParameter("ContractPosition.Count"));
	// Cancel
	if(actionCancel) {
	  session.setAttribute(wizardName, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
%>
<!--
	<meta name="UNUSEDlabel" content="Create Contract">
	<meta name="UNUSEDtoolTip" content="Create Contract">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:contract1:Segment">
	<meta name="order" content="org:opencrx:kernel:contract1:Segment:createOpportunity">
	<meta name="order" content="org:opencrx:kernel:contract1:Segment:createQuote">
	<meta name="order" content="org:opencrx:kernel:contract1:Segment:createSalesOrder">
	<meta name="order" content="org:opencrx:kernel:contract1:Segment:createInvoice">
-->
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
    org.opencrx.kernel.contract1.jmi1.Segment contractSegment = (org.opencrx.kernel.contract1.jmi1.Segment)pm.getObjectById(
        new Path("xri:@openmdx:org.opencrx.kernel.contract1/provider/" + providerName + "/segment/" + segmentName)
    );
    // Main form
	org.openmdx.ui1.jmi1.FormDefinition formDefinition = app.getUiFormDefinition(formName);
	org.openmdx.portal.servlet.control.FormControl form = new org.openmdx.portal.servlet.control.FormControl(
		formDefinition.refGetPath().getBase(),
		app.getCurrentLocaleAsString(),
		app.getCurrentLocaleAsIndex(),
		app.getUiContext(),
		formDefinition
	);
	// Create position form
	org.openmdx.ui1.jmi1.FormDefinition contractPositionFormDefinition = app.getUiFormDefinition("CreateContractPositionForm");
	org.openmdx.portal.servlet.control.FormControl contractPositionForm = new org.openmdx.portal.servlet.control.FormControl(
		formDefinition.refGetPath().getBase(),
		app.getCurrentLocaleAsString(),
		app.getCurrentLocaleAsIndex(),
		app.getUiContext(),
		contractPositionFormDefinition
	);
	Map formValues = new HashMap();
	form.updateObject(
		request.getParameterMap(),
		formValues,
		app,
		pm
	);
	contractPositionForm.updateObject(
		request.getParameterMap(),
		formValues,
		app,
		pm
	);
	// Get position values
	for(int i = 0; i < 100; i++) {
	    formValues.put(
	        "position.quantity." + i,
	        request.getParameter("position.quantity." + i)
	    );
	    formValues.put(
	        "position.product." + i,
	        request.getParameter("position.product." + i)
	    );
	    formValues.put(
	        "position.product.xri." + i,
	        request.getParameter("position.product.xri." + i)
	    );
	    formValues.put(
	        "position.name." + i,
	        request.getParameter("position.name." + i)
	    );
	    formValues.put(
	        "position.pricePerUnit." + i,
	        request.getParameter("position.pricePerUnit." + i)
	    );
	    formValues.put(
	        "position.amount." + i,
	        request.getParameter("position.amount." + i)
	    );
	}
	// Set defaults
	if(obj instanceof org.opencrx.kernel.account1.jmi1.Account) {
	    org.opencrx.kernel.account1.jmi1.Account customer = (org.opencrx.kernel.account1.jmi1.Account)obj;
	    formValues.put(
	        "org:opencrx:kernel:contract1:SalesContract:customer",
	        customer.refGetPath()
	    );
	    formValues.put(
	        "org:opencrx:kernel:contract1:AbstractContract:activeOn",
	        new Date()
	    );
        actionRefresh = true;
	}
	// Refresh
	org.opencrx.kernel.account1.jmi1.Account customer = formValues.get("org:opencrx:kernel:contract1:SalesContract:customer") != null ?
		(org.opencrx.kernel.account1.jmi1.Account)pm.getObjectById(
			formValues.get("org:opencrx:kernel:contract1:SalesContract:customer")
		) : null;
	if(actionRefresh) {
	    // Contract number
	    if(customer != null) {
	        String contractNumber = (String)formValues.get("org:opencrx:kernel:contract1:AbstractContract:contractNumber");
	        if(
	            (contractNumber == null) &&
	            (customer.getAliasName() != null)
	        ) {
	            contractNumber = customer.getAliasName() + "-?" + (System.currentTimeMillis() / 1000);
	            formValues.put(
	                "org:opencrx:kernel:contract1:AbstractContract:contractNumber",
	                contractNumber
	            );
	        }
	        if(formValues.get("org:opencrx:kernel:contract1:AbstractContract:name") == null) {
	            formValues.put(
	                "org:opencrx:kernel:contract1:AbstractContract:name",
	                contractNumber
	            );
	        }
	    }
	    // Pricing rule
	    org.opencrx.kernel.product1.jmi1.PricingRule pricingRule = formValues.get("org:opencrx:kernel:contract1:SalesContract:pricingRule") != null ?
	        (org.opencrx.kernel.product1.jmi1.PricingRule)pm.getObjectById(
	        	formValues.get("org:opencrx:kernel:contract1:SalesContract:pricingRule")
	        ) : null;
	    org.opencrx.kernel.product1.jmi1.Segment productSegment = (org.opencrx.kernel.product1.jmi1.Segment)pm.getObjectById(
	        new Path("xri:@openmdx:org.opencrx.kernel.product1/provider/" + providerName + "/segment/" + segmentName)
	    );
	    if(pricingRule == null) {
	        pricingRule = Products.getInstance().findPricingRule(Products.PRICING_RULE_NAME_LOWEST_PRICE, productSegment, pm);
	        if(pricingRule != null) {
	            formValues.put(
	                "org:opencrx:kernel:contract1:SalesContract:pricingRule",
	                pricingRule.refGetPath()
	            );
	        }
	    }
	    // Calculation Rule
	    org.opencrx.kernel.contract1.jmi1.CalculationRule calcRule = formValues.get("org:opencrx:kernel:contract1:SalesContract:calcRule") != null ?
	        (org.opencrx.kernel.contract1.jmi1.CalculationRule)pm.getObjectById(
	        	formValues.get("org:opencrx:kernel:contract1:SalesContract:calcRule")
	        ) : null;
	    if(calcRule == null) {
	        calcRule = Contracts.getInstance().findCalculationRule(Contracts.CALCULATION_RULE_NAME_DEFAULT, contractSegment, pm);
	        if(calcRule != null) {
	            formValues.put(
	                "org:opencrx:kernel:contract1:SalesContract:calcRule",
	                calcRule.refGetPath()
	            );
	        }
	    }
	}
	if(actionSetShippingAddress && (addressXri != null)) {
	    org.opencrx.kernel.account1.jmi1.PostalAddress address = (org.opencrx.kernel.account1.jmi1.PostalAddress)pm.getObjectById(new Path(addressXri));
	    formValues.put(
	        "org:opencrx:kernel:account1:Contact:address!postalAddressLine",
			new ArrayList(address.getPostalAddressLine())
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Contact:address!postalStreet",
			new ArrayList(address.getPostalStreet())
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Contact:address!postalCity",
			address.getPostalCity()
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Contact:address!postalCode",
			address.getPostalCode()
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Contact:address!postalCountry",
			address.getPostalCountry()
	    );
	}
	if(actionSetBillingAddress && (addressXri != null)) {
	    org.opencrx.kernel.account1.jmi1.PostalAddress address = (org.opencrx.kernel.account1.jmi1.PostalAddress)pm.getObjectById(new Path(addressXri));
	    formValues.put(
	        "org:opencrx:kernel:account1:Account:address*Business!postalAddressLine",
			new ArrayList(address.getPostalAddressLine())
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Account:address*Business!postalStreet",
			new ArrayList(address.getPostalStreet())
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Account:address*Business!postalCity",
			address.getPostalCity()
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Account:address*Business!postalCode",
			address.getPostalCode()
	    );
	    formValues.put(
	        "org:opencrx:kernel:account1:Account:address*Business!postalCountry",
			address.getPostalCountry()
	    );
	}
	if(actionAddPosition) {
	    org.opencrx.kernel.product1.jmi1.Product product = formValues.get("org:opencrx:kernel:product1:ProductDescriptor:product") != null ?
	    	(org.opencrx.kernel.product1.jmi1.Product)pm.getObjectById(
	    		formValues.get("org:opencrx:kernel:product1:ProductDescriptor:product")
	    	) : null;
	    java.math.BigDecimal quantity = (java.math.BigDecimal)formValues.get("org:opencrx:kernel:contract1:SalesContractPosition:quantity");
	    String positionName = (String)formValues.get("org:opencrx:kernel:contract1:SalesContractPosition:name");
	    if(
	        (product != null) &&
	        (quantity != null)
	    ) {
	        String productTitle = new ObjectReference(product, app).getTitle();
	        formValues.put(
	            "position.quantity." + contractPositionCount,
	            quantity.toString()
	        );
	        formValues.put(
	            "position.product." + contractPositionCount,
	            productTitle
	        );
	        formValues.put(
	            "position.product.xri." + contractPositionCount,
	            product.refMofId()
	        );
	        formValues.put(
	            "position.name." + contractPositionCount,
	            (positionName == null) || (positionName.length() == 0) ?
	                productTitle :
	                positionName
	        );
	        org.opencrx.kernel.product1.jmi1.ProductBasePrice candidate = null;
            Short contractCurrency = (Short)formValues.get("org:opencrx:kernel:contract1:SalesContract:contractCurrency");
	        FindPrice: for(Iterator i = product.getBasePrice().iterator(); i.hasNext(); ) {
	            org.opencrx.kernel.product1.jmi1.ProductBasePrice price = (org.opencrx.kernel.product1.jmi1.ProductBasePrice)i.next();
	            // Find a price which matches currency, quantity, uom and which
	            // is assigned to a valid price level
	            if(
	                (contractCurrency.compareTo(price.getPriceCurrency()) == 0) &&
	                ((price.getQuantityFrom() == null) || (price.getQuantityFrom().compareTo(quantity) <= 0)) &&
	                ((price.getQuantityTo() == null) || (price.getQuantityTo().compareTo(quantity) >= 0)) &&
	                (product.getDefaultUom() != null) &&
	                product.getDefaultUom().equals(price.getUom())
	            ) {
	                Date now = new Date();
	                if (formValues.get("org:opencrx:kernel:contract1:AbstractContract:activeOn") != null) {
	                   try {
	                       now = (Date)formValues.get("org:opencrx:kernel:contract1:AbstractContract:activeOn");
	                   } catch (Exception e) {}
	                }

	                for(Iterator j = price.getPriceLevel().iterator(); j.hasNext(); ) {
						org.opencrx.kernel.product1.jmi1.PriceLevel priceLevel = (org.opencrx.kernel.product1.jmi1.PriceLevel)j.next();
						if(
						    ((priceLevel.isDisabled() == null) || !priceLevel.isDisabled()) &&
						    ((priceLevel.getValidFrom() == null) || (priceLevel.getValidFrom().compareTo(now) <= 0)) &&
						    ((priceLevel.getValidTo() == null) || (priceLevel.getValidTo().compareTo(now) >= 0))
						) {
			                candidate = price;
			                break FindPrice;
						}
	                }
	            }
	        }
	        java.math.BigDecimal pricePerUnit = candidate == null ?
	            java.math.BigDecimal.ZERO :
	            candidate.getPrice();
	        formValues.put(
	            "position.pricePerUnit." + contractPositionCount,
	            pricePerUnit.toString()
	        );
	        formValues.put(
	            "position.amount." + contractPositionCount,
	            quantity.multiply(pricePerUnit).toString()
	        );
	        contractPositionCount++;
	    }
	}
	if(actionDeletePosition) {
	    formValues.remove("position.quantity." + deletePositionIndex);
	    formValues.remove("position.product." + deletePositionIndex);
	    formValues.remove("position.product.xri." + deletePositionIndex);
	    formValues.remove("position.name." + deletePositionIndex);
	    formValues.remove("position.pricePerUnit." + deletePositionIndex);
	    formValues.remove("position.amount." + deletePositionIndex);
	}
	if(actionCreateQuote || actionCreateSalesOrder || actionCreateInvoice || actionCreateOpportunity) {
	    String name = (String)formValues.get("org:opencrx:kernel:contract1:AbstractContract:name");
	    String contractNumber = (String)formValues.get("org:opencrx:kernel:contract1:AbstractContract:contractNumber");
	    org.opencrx.kernel.account1.jmi1.Account account = formValues.get("org:opencrx:kernel:contract1:SalesContract:customer") != null ?
	        (org.opencrx.kernel.account1.jmi1.Account)pm.getObjectById(
	        	formValues.get("org:opencrx:kernel:contract1:SalesContract:customer")
	        ) : null;
	    List postalAddressLineShipping = (List)formValues.get("org:opencrx:kernel:account1:Contact:address!postalAddressLine");
	    List postalStreetShipping = (List)formValues.get("org:opencrx:kernel:account1:Contact:address!postalStreet");
	    List postalAddressLineBilling = (List)formValues.get("org:opencrx:kernel:account1:Account:address*Business!postalAddressLine");
	    List postalStreetBilling = (List)formValues.get("org:opencrx:kernel:account1:Account:address*Business!postalStreet");
	    if(
	        (name != null) && (name.length() > 0) &&
	        (contractNumber != null) && (contractNumber.length() > 0) &&
	        (account != null) &&
	        (!postalAddressLineShipping.isEmpty() || !postalStreetShipping.isEmpty()) &&
	        (!postalAddressLineBilling.isEmpty() || !postalStreetBilling.isEmpty())
	    ) {
		    org.opencrx.kernel.contract1.jmi1.SalesContract contract = null;
		    if(actionCreateOpportunity) {
		        contract = pm.newInstance(org.opencrx.kernel.contract1.jmi1.Opportunity.class);
		    }
	    	else if(actionCreateQuote) {
		        contract = pm.newInstance(org.opencrx.kernel.contract1.jmi1.Quote.class);
		    }
		    else if(actionCreateQuote) {
		        contract = pm.newInstance(org.opencrx.kernel.contract1.jmi1.Quote.class);
		    }
		    else if(actionCreateSalesOrder) {
		        contract = pm.newInstance(org.opencrx.kernel.contract1.jmi1.SalesOrder.class);
		    }
		    else {
		        contract = pm.newInstance(org.opencrx.kernel.contract1.jmi1.Invoice.class);
		    }
		    org.opencrx.kernel.product1.jmi1.PricingRule pricingRule = formValues.get("org:opencrx:kernel:contract1:SalesContract:pricingRule") != null ?
		        (org.opencrx.kernel.product1.jmi1.PricingRule)pm.getObjectById(
		        	formValues.get("org:opencrx:kernel:contract1:SalesContract:pricingRule")
		        ) : null;
			contract.refInitialize(false, false);
			contract.setDescription((String)formValues.get("org:opencrx:kernel:contract1:AbstractContract:description"));
			contract.setCustomer(account);
			contract.setActiveOn((Date)formValues.get("org:opencrx:kernel:contract1:AbstractContract:activeOn"));
			contract.setContractCurrency((Short)formValues.get("org:opencrx:kernel:contract1:SalesContract:contractCurrency"));
			contract.setPriority((Short)formValues.get("org:opencrx:kernel:contract1:AbstractContract:priority"));
			contract.setSalesRep(
				formValues.get("org:opencrx:kernel:contract1:SalesContract:salesRep") != null ?
					(org.opencrx.kernel.account1.jmi1.Account)pm.getObjectById(
						formValues.get("org:opencrx:kernel:contract1:SalesContract:salesRep")
					) : null
			);
			contract.setExpiresOn((Date)formValues.get("org:opencrx:kernel:contract1:AbstractContract:expiresOn"));
			contract.setPaymentTerms((Short)formValues.get("org:opencrx:kernel:contract1:SalesContract:paymentTerms"));
			contract.setOrigin(
				formValues.get("org:opencrx:kernel:contract1:AbstractContract:origin") != null ?
					(org.opencrx.kernel.contract1.jmi1.SalesContract)pm.getObjectById(
						formValues.get("org:opencrx:kernel:contract1:SalesContract:origin")
					) : null
			);
			contract.setPricingRule(pricingRule);
			contract.setCalcRule(
				formValues.get("org:opencrx:kernel:contract1:SalesContract:calcRule") != null ?
					(org.opencrx.kernel.contract1.jmi1.CalculationRule)pm.getObjectById(
						formValues.get("org:opencrx:kernel:contract1:SalesContract:calcRule")
					) : null
			);
			//contract.setPricingDate(new Date());
			contract.setShippingMethod((Short)formValues.get("org:opencrx:kernel:contract1:ShippingDetail:shippingMethod"));
			pm.currentTransaction().begin();
			if(actionCreateOpportunity) {
				contract.setContractNumber(contractNumber.replace("?", "P"));
				contract.setName(name.replace("?", "P"));
				contractSegment.addOpportunity(
				    false,
				    org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
				    (org.opencrx.kernel.contract1.jmi1.Opportunity)contract
				);
			}
			else if(actionCreateQuote) {
				contract.setContractNumber(contractNumber.replace("?", "Q"));
				contract.setName(name.replace("?", "Q"));
				contractSegment.addQuote(
				    false,
				    org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
				    (org.opencrx.kernel.contract1.jmi1.Quote)contract
				);
			}
			else if(actionCreateSalesOrder) {
				contract.setContractNumber(contractNumber.replace("?", "S"));
				contract.setName(name.replace("?", "S"));
				((org.opencrx.kernel.contract1.jmi1.SalesOrder)contract).setSubmitDate(new Date());
				contractSegment.addSalesOrder(
				    false,
				    org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
				    (org.opencrx.kernel.contract1.jmi1.SalesOrder)contract
				);
			}
			else if(actionCreateInvoice) {
				contract.setContractNumber(contractNumber.replace("?", "I"));
				contract.setName(name.replace("?", "I"));
				contractSegment.addInvoice(
				    false,
				    org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
				    (org.opencrx.kernel.contract1.jmi1.Invoice)contract
				);
			}
			pm.currentTransaction().commit();
			// Shipping address
			org.opencrx.kernel.contract1.jmi1.PostalAddress shippingAddress = pm.newInstance(org.opencrx.kernel.contract1.jmi1.PostalAddress.class);
			shippingAddress.refInitialize(false, false);
			shippingAddress.getUsage().add((short)10200); // Delivery
			shippingAddress.setPostalAddressLine(postalAddressLineShipping);
			shippingAddress.setPostalStreet(postalStreetShipping);
			shippingAddress.setPostalCity((String)formValues.get("org:opencrx:kernel:account1:Contact:address!postalCity"));
			shippingAddress.setPostalCode((String)formValues.get("org:opencrx:kernel:account1:Contact:address!postalCode"));
			shippingAddress.setPostalCountry((Short)formValues.get("org:opencrx:kernel:account1:Contact:address!postalCountry"));
			// Billing address
			org.opencrx.kernel.contract1.jmi1.PostalAddress billingAddress = pm.newInstance(org.opencrx.kernel.contract1.jmi1.PostalAddress.class);
			billingAddress.refInitialize(false, false);
			billingAddress.getUsage().add((short)10000); // Invoice
			billingAddress.setPostalAddressLine(postalAddressLineBilling);
			billingAddress.setPostalStreet(postalStreetBilling);
			billingAddress.setPostalCity((String)formValues.get("org:opencrx:kernel:account1:Account:address*Business!postalCity"));
			billingAddress.setPostalCode((String)formValues.get("org:opencrx:kernel:account1:Account:address*Business!postalCode"));
			billingAddress.setPostalCountry((Short)formValues.get("org:opencrx:kernel:account1:Account:address*Business!postalCountry"));
			// Add addresses
			pm.currentTransaction().begin();
			contract.addAddress(
			    false,
			    org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
			    shippingAddress
			);
			contract.addAddress(
			    false,
			    org.opencrx.kernel.backend.Contracts.getInstance().getUidAsString(),
			    billingAddress
			);
			pm.currentTransaction().commit();
			// Create positions
			for(int i = 0; i < 100; i++) {
				String quantity = (String)formValues.get("position.quantity." + i);
			    String productXri = (String)formValues.get("position.product.xri." + i);
			    String positionName = (String)formValues.get("position.name." + i);
			    String pricePerUnit = (String)formValues.get("position.pricePerUnit." + i);
			    if(productXri != null) {
				    org.opencrx.kernel.contract1.jmi1.CreatePositionParams params = org.opencrx.kernel.utils.Utils.getContractPackage(pm).createCreatePositionParams(
			            Boolean.TRUE,
			            positionName,
			            null, // default UOM
			            null, // use pricing date from contract
			            pricingRule,
			            (org.opencrx.kernel.product1.jmi1.Product)pm.getObjectById(new Path(productXri)),
			            app.parseNumber(quantity),
			            null // default UOM
				    );
				    try {
					    pm.currentTransaction().begin();
					    org.opencrx.kernel.contract1.jmi1.CreatePositionResult result = contract.createPosition(params);
					    pm.currentTransaction().commit();
					    if(pricePerUnit != null) {
                org.opencrx.kernel.contract1.jmi1.SalesContractPosition position = result.getPosition();
                pm.refresh(position);
                pm.currentTransaction().begin();
                position.setPricePerUnit(app.parseNumber(pricePerUnit));
                //position.setPricingDate(null);
                pm.currentTransaction().commit();
					    }
				    }
				    catch(Exception e) {
				        ServiceException e0 = new ServiceException(e);
				        e0.log();
				        try {
				            pm.currentTransaction().rollback();
				        } catch(Exception e1) {}
				    }
			    }
			}
			// Forward
		    Action nextAction = new ObjectReference(
		    	contract,
		    	app
		   	).getSelectObjectAction();
			response.sendRedirect(
				request.getContextPath() + "/" + nextAction.getEncodedHRef()
			);
			return;
	    }
	}
	TransientObjectView view = new TransientObjectView(
		formValues,
		app,
		obj,
		pm
	);
	ViewPort p = ViewPortFactory.openPage(
		view,
		request,
		out
	);
%>
<br />
<form id="<%= formName %>" name="<%= formName %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
	<input type="Hidden" id="Command" name="Command" value="Refresh" />
	<table cellspacing="8" class="tableLayout">
		<tr>
			<td class="cellObject">
				<div class="panel" id="panel<%= formName %>" style="display: block">
<%
					form.paint(
						p,
						null, // frame
						true // forEditing
					);
					p.flush();

					// Contract positions
					if(contractPositionCount > 0) {
%>
						<div class="fieldGroupName">Positions</div>
						<div>&nbsp;</div>
						<table class="gridTableFull">
							<tr class="gridTableHeaderFull">
								<td />
								<td><%= view.getFieldLabel("org:opencrx:kernel:contract1:SalesContractPosition", "quantity", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:ProductDescriptor", "product", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:contract1:SalesContractPosition", "name", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:contract1:SalesContractPosition", "pricePerUnit", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:contract1:SalesContractPosition", "baseAmount", app.getCurrentLocaleAsIndex()) %></td>
								<td class="addon"/>
							</tr>
<%
							int lastContractPositionIndex = -1;
							for(int i = 0; i < contractPositionCount; i++) {
							    if(formValues.get("position.product.xri." + i) != null) {
							        lastContractPositionIndex = i;
%>
									<tr class="gridTableRowFull">
										<td><input class="abutton" type="submit" name="DeletePosition.<%= i %>" value="-" onclick="javascript:$('Command').value=this.name"/></td>
										<td><input class="valueR" type="text" name="position.quantity.<%= i %>" value="<%= formValues.get("position.quantity." + i) %>"/></td>
										<td><input class="valueL" type="text" readonly name="position.product.<%= i %>" value="<%= formValues.get("position.product." + i) %>"/><input type="hidden" name="position.product.xri.<%= i %>" value="<%= formValues.get("position.product.xri." + i) %>"/></td>
										<td><input class="valueL" type="text" name="position.name.<%= i %>" value="<%= formValues.get("position.name." + i) %>"/></td>
										<td><input class="valueR" type="text" name="position.pricePerUnit.<%= i %>" value="<%= formValues.get("position.pricePerUnit." + i) %>"/></td>
										<td><input class="valueR" type="text" readonly name="position.amount.<%= i %>" value="<%= formValues.get("position.amount." + i) %>"/></td>
										<td class="addon"/>
									</tr>
<%
							    }
							}
							contractPositionCount = lastContractPositionIndex + 1;
%>
						</table>
<%
					}
					contractPositionForm.paint(
						p,
						null, // frame
						true // forEditing
					);
					p.flush();
%>
					<input type="hidden" name="ContractPosition.Count" id="ContractPosition.Count" value="<%= contractPositionCount %>" />
					<input type="submit" class="abutton" name="AddPosition" id="AddPosition.Button" tabindex="9000" value="+" onclick="javascript:$('Command').value=this.name"/>
					<div class="fieldGroupName">&nbsp;</div>
				</div>
				<input type="submit" class="abutton" name="Refresh" id="Refresh.Button" tabindex="9010" value="Refresh" onclick="javascript:$('Command').value=this.name;"/>
				<input type="submit" class="abutton" name="CreateOpportunity" id="CreateOpportunity.Button" tabindex="9020" value="Create Opportunity" onclick="javascript:$('Command').value=this.name;" />
				<input type="submit" class="abutton" name="CreateQuote" id="CreateQuote.Button" tabindex="9030" value="Create Quote" onclick="javascript:$('Command').value=this.name;" />
				<input type="submit" class="abutton" name="CreateSalesOrder" id="CreateSalesOrder.Button" tabindex="9040" value="Create Sales Order" onclick="javascript:$('Command').value=this.name;" />
				<input type="submit" class="abutton" name="CreateInvoice" id="CreateInvoice.Button" tabindex="9050" value="Create Invoice" onclick="javascript:$('Command').value=this.name;" />
				<input type="submit" class="abutton" name="Cancel" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
<%
				if(customer != null) {
%>
					<div>&nbsp;</div>
					<table class="gridTableFull">
						<tr class="gridTableHeaderFull">
							<td><%= view.getFieldLabel("org:opencrx:kernel:contract1:AccountAddress", "address", app.getCurrentLocaleAsIndex()) %></td>
							<td>Set as shipping address</td>
							<td>Set as billing address</td>
							<td class="addon"/>
						</tr>
<%
						org.opencrx.kernel.account1.cci2.AccountAddressQuery addressQuery = (org.opencrx.kernel.account1.cci2.AccountAddressQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.PostalAddress.class);
						List addresses = customer.getAddress(addressQuery);
						int ii = 0;
						for(Iterator i = addresses.iterator(); i.hasNext(); ) {
						    org.opencrx.kernel.account1.jmi1.AccountAddress address = (org.opencrx.kernel.account1.jmi1.AccountAddress)i.next();
%>
							<tr class="gridTableRowFull">
								<td><%= new ObjectReference(address, app).getTitle() %><input type="Hidden" id="addressXri.<%= Integer.toString(ii) %>" name="addressXri.<%= Integer.toString(ii) %>" value="<%= address.refMofId() %>"/></td>
								<td><input type="submit" class="abutton" id="Button.SetShippingAddress.<%= Integer.toString(ii) %>" name="SetShippingAddress.<%= Integer.toString(ii) %>" value="Shipping" onclick="javascript:$('Command').value=this.name"/>
								<td><input type="submit" class="abutton" id="Button.SetBillingAddress.<%= Integer.toString(ii) %>" name="SetBillingAddress.<%= Integer.toString(ii) %>" value="Billing" onclick="javascript:$('Command').value=this.name"/>
								<td class="addon"/>
							</tr>
<%
							ii++;
						}
%>
					</table>
<%
				}
%>
			</td>
		</tr>
	</table>
</form>
<script language="javascript" type="text/javascript">
	Event.observe('<%= formName %>', 'submit', function(event) {
		$('<%= formName %>').request({
			onFailure: function() { },
			onSuccess: function(t) {
				$('UserDialog').update(t.responseText);
			}
		});
		Event.stop(event);
	});
</script>
<%
p.close(false);
if(pm != null) {
	pm.close();
}
%>
