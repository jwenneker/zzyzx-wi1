<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: CreateProductWizard.jsp,v 1.16 2011/11/02 16:30:55 cmu Exp $
 * Description: CreateProduct wizard
 * Revision:    $Revision: 1.16 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/02 16:30:55 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2005-2010, CRIXP Corp., Switzerland
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
	String formName = "CreateProductForm";
	String wizardName = "CreateProductWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";								
	boolean actionOk = "OK".equals(command);
	boolean actionCancel = "Cancel".equals(command);
	boolean actionAddProductBasePrice = "AddProductBasePrice".equals(command);
	int productBasePriceCount = request.getParameter("ProductBasePrice.Count") == null ?
	    0 :
	    Integer.valueOf(request.getParameter("ProductBasePrice.Count"));
	// Delete product base price
	boolean actionDeleteProductBasePrice = false;
	int deleteProductBasePriceIndex = 0;
	for(int i = 0; i < 100; i++) {
	    actionDeleteProductBasePrice = command.equals("DeleteProductBasePrice." + i);
	    if(actionDeleteProductBasePrice) {
	        deleteProductBasePriceIndex = i;
	        break;
	    }
	}
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
	<meta name="UNUSEDlabel" content="Create Product">
	<meta name="UNUSEDtoolTip" content="Create Product">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:product1:Segment">
	<meta name="order" content="org:opencrx:kernel:product1:Segment:createProduct">
-->	
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	org.opencrx.kernel.product1.jmi1.Segment productSegment = (org.opencrx.kernel.product1.jmi1.Segment)pm.getObjectById(
	    new Path("xri:@openmdx:org.opencrx.kernel.product1/provider/" + providerName + "/segment/" + segmentName)
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
	// Product base price form
	org.openmdx.ui1.jmi1.FormDefinition productBasePriceFormDefinition = app.getUiFormDefinition("ProductBasePriceForm");
	org.openmdx.portal.servlet.control.FormControl productBasePriceForm = new org.openmdx.portal.servlet.control.FormControl(
		formDefinition.refGetPath().getBase(),
		app.getCurrentLocaleAsString(),
		app.getCurrentLocaleAsIndex(),
		app.getUiContext(),
		productBasePriceFormDefinition
	);
	Map formValues = new HashMap();
	form.updateObject(
		request.getParameterMap(),
		formValues,
		app,
		pm
	);
	productBasePriceForm.updateObject(
		request.getParameterMap(),
		formValues,
		app,
		pm
	);
	// Get product base price values
	for(int i = 0; i < 100; i++) {
	    if(request.getParameter("productBasePrice.priceLevel." + i) != null) {
	        List usage = new ArrayList();
	        StringTokenizer tokenizer = new StringTokenizer(request.getParameter("productBasePrice.usage." + i), ",[] ", false);
	        while(tokenizer.hasMoreTokens()) {
	            usage.add(Short.valueOf(tokenizer.nextToken()));
	        }
		    formValues.put(
		        "productBasePrice.usage." + i,
		        usage
		    );
		    formValues.put(
		        "productBasePrice.priceLevel." + i,
		        new Path(request.getParameter("productBasePrice.priceLevel." + i))
		    );
		    formValues.put(
		        "productBasePrice.price." + i,
		        app.parseNumber(request.getParameter("productBasePrice.price." + i))
		    );
		    formValues.put(
		        "productBasePrice.priceCurrency." + i,
		        Short.valueOf(request.getParameter("productBasePrice.priceCurrency." + i))
		    );
		    formValues.put(
		        "productBasePrice.quantityFrom." + i,
		        app.parseNumber(request.getParameter("productBasePrice.quantityFrom." + i))
		    );
		    formValues.put(
		        "productBasePrice.quantityTo." + i,
		        app.parseNumber(request.getParameter("productBasePrice.quantityTo." + i))
		    );
		    formValues.put(
		        "productBasePrice.discountIsPercentage." + i,
		        "on".equals(request.getParameter("productBasePrice.discountIsPercentage." + i))
		    );
		    formValues.put(
		        "productBasePrice.discount." + i,
		        app.parseNumber(request.getParameter("productBasePrice.discount." + i))
		    );
	    }
	}
	if(actionDeleteProductBasePrice) {
	    formValues.remove("productBasePrice.priceLevel." + deleteProductBasePriceIndex);
	    formValues.remove("productBasePrice.usage." + deleteProductBasePriceIndex);
	    formValues.remove("productBasePrice.price." + deleteProductBasePriceIndex);
	    formValues.remove("productBasePrice.priceCurrency." + deleteProductBasePriceIndex);
	    formValues.remove("productBasePrice.quantityFrom." + deleteProductBasePriceIndex);
	    formValues.remove("productBasePrice.quantityTo." + deleteProductBasePriceIndex);
	    formValues.remove("productBasePrice.discountIsPercentage." + deleteProductBasePriceIndex);
	    formValues.remove("productBasePrice.discount." + deleteProductBasePriceIndex);
	}
	if(actionAddProductBasePrice) {
	    org.opencrx.kernel.product1.jmi1.PriceLevel priceLevel = formValues.get("org:opencrx:kernel:product1:AbstractPriceLevel:basedOn") != null ?
	    	(org.opencrx.kernel.product1.jmi1.PriceLevel)pm.getObjectById(
	    		formValues.get("org:opencrx:kernel:product1:AbstractPriceLevel:basedOn")
	    	) : null;
	    java.math.BigDecimal price = (java.math.BigDecimal)formValues.get("org:opencrx:kernel:product1:AbstractProductPrice:price");
	    Short priceCurrency = priceLevel == null ? null : priceLevel.getPriceCurrency();
	    List usage = (List)formValues.get("org:opencrx:kernel:product1:AbstractProductPrice:usage");
	    if(
	        (priceLevel != null) &&
	        (price != null) &&
	        (priceCurrency != null) &&
	        (usage != null)
	    ) {
	        formValues.put(
	            "productBasePrice.usage." + productBasePriceCount,
	            usage
	        );
	        formValues.put(
	            "productBasePrice.priceLevel." + productBasePriceCount,
	            priceLevel.refGetPath()
	        );
	        formValues.put(
	            "productBasePrice.price." + productBasePriceCount,
	            price
	        );
	        formValues.put(
	            "productBasePrice.priceCurrency." + productBasePriceCount,
	            priceCurrency
	        );
	        formValues.put(
	            "productBasePrice.quantityFrom." + productBasePriceCount,
	            formValues.get("org:opencrx:kernel:product1:AbstractProductPrice:quantityFrom")
	        );
	        formValues.put(
	            "productBasePrice.quantityTo." + productBasePriceCount,
	            formValues.get("org:opencrx:kernel:product1:AbstractProductPrice:quantityTo")
	        );
	        formValues.put(
	            "productBasePrice.discountIsPercentage." + productBasePriceCount,
	            formValues.get("org:opencrx:kernel:product1:AbstractProductPrice:discountIsPercentage")
	        );
	        formValues.put(
	            "productBasePrice.discount." + productBasePriceCount,
	            formValues.get("org:opencrx:kernel:product1:AbstractProductPrice:discount")
	        );
	        productBasePriceCount++;
	    }
	}
	if(actionOk) {
	    String productName = (String)formValues.get("org:opencrx:kernel:product1:AbstractProduct:name");
	    String productNumber = (String)formValues.get("org:opencrx:kernel:product1:AbstractProduct:productNumber");
	    org.opencrx.kernel.product1.jmi1.SalesTaxType salesTaxType = formValues.get("org:opencrx:kernel:product1:AbstractProduct:salesTaxType") != null ?
	    	(org.opencrx.kernel.product1.jmi1.SalesTaxType)pm.getObjectById(
	    		formValues.get("org:opencrx:kernel:product1:AbstractProduct:salesTaxType")
	    	) : null;
	    org.opencrx.kernel.uom1.jmi1.Uom defaultUom = formValues.get("org:opencrx:kernel:product1:AbstractProduct:defaultUom") != null ?
	    	(org.opencrx.kernel.uom1.jmi1.Uom)pm.getObjectById(
	    		formValues.get("org:opencrx:kernel:product1:AbstractProduct:defaultUom")
	    	) : null;
	    if(
	        (productName != null) &&
	        (productNumber != null) &&
	        (salesTaxType != null) &&
	        (defaultUom != null)
	    ) {
	        org.opencrx.kernel.product1.jmi1.Product product = pm.newInstance(org.opencrx.kernel.product1.jmi1.Product.class);
	        product.refInitialize(false, false);
	        product.setName(productName);
	        product.setProductState((Short)formValues.get("org:opencrx:kernel:product1:AbstractProduct:productState"));
	        product.setProductNumber(productNumber);
	        product.setDefaultUom(defaultUom);
	        product.getPriceUom().add(defaultUom);
	        product.setActiveOn((Date)formValues.get("org:opencrx:kernel:product1:AbstractProduct:activeOn"));
	        product.setExpiresOn((Date)formValues.get("org:opencrx:kernel:product1:AbstractProduct:expiresOn"));
	        product.setSalesTaxType(salesTaxType);
	        product.setGrossWeightKilogram((java.math.BigDecimal)formValues.get("org:opencrx:kernel:product1:Product:grossWeightKilogram"));
	        product.setNetWeightKilogram((java.math.BigDecimal)formValues.get("org:opencrx:kernel:product1:Product:netWeightKilogram"));
	        product.setProductDimension((String)formValues.get("org:opencrx:kernel:product1:Product:productDimension"));
	        product.setDescription((String)formValues.get("org:opencrx:kernel:product1:AbstractProduct:description"));
	        product.setDetailedDescription((String)formValues.get("org:opencrx:kernel:product1:AbstractProduct:detailedDescription"));
	        pm.currentTransaction().begin();
	        productSegment.addProduct(
	            false,
	            org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
	            product
	        );
	        pm.currentTransaction().commit();
			// Create product base prices
			pm.currentTransaction().begin();
			for(int i = 0; i < 100; i++) {
			    if(formValues.get("productBasePrice.priceLevel." + i) != null) {
			        org.opencrx.kernel.product1.jmi1.ProductBasePrice basePrice = pm.newInstance(org.opencrx.kernel.product1.jmi1.ProductBasePrice.class);
			        basePrice.refInitialize(false, false);
				    basePrice.getPriceLevel().add(
				    	(org.opencrx.kernel.product1.jmi1.PriceLevel)pm.getObjectById(
				    		formValues.get("productBasePrice.priceLevel." + i)
				    	)
				    );
				    basePrice.setUom(defaultUom);
				    basePrice.getUsage().addAll((List)formValues.get("productBasePrice.usage." + i));
				    basePrice.setPrice((java.math.BigDecimal)formValues.get("productBasePrice.price." + i));
				    basePrice.setPriceCurrency((Short)formValues.get("productBasePrice.priceCurrency." + i));
				    basePrice.setQuantityFrom((java.math.BigDecimal)formValues.get("productBasePrice.quantityFrom." + i));
				    basePrice.setQuantityTo((java.math.BigDecimal)formValues.get("productBasePrice.quantityTo." + i));
				    basePrice.setDiscountIsPercentage((Boolean)formValues.get("productBasePrice.discountIsPercentage." + i));
				    basePrice.setDiscount((java.math.BigDecimal)formValues.get("productBasePrice.discount." + i));
				    product.addBasePrice(
				        false,
				        org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
				        basePrice
				    );
			    }
			}
			pm.currentTransaction().commit();
			// Forward to created product
		    Action nextAction = new ObjectReference(
		    	product,
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
	<input type="hidden" id="Command" name="Command" value="" />											
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

					// Product base prices
					if(productBasePriceCount > 0) {
%>
						<div class="fieldGroupName">Prices</div>
						<div>&nbsp;</div>
						<table class="gridTableFull">
							<tr class="gridTableHeaderFull">
								<td />
								<td><%= app.getLabel("org:opencrx:kernel:product1:PriceLevel") %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:AbstractProductPrice", "usage", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:AbstractProductPrice", "priceCurrency", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:AbstractProductPrice", "quantityFrom", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:AbstractProductPrice", "quantityTo", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:AbstractProductPrice", "price", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:AbstractProductPrice", "discountIsPercentage", app.getCurrentLocaleAsIndex()) %></td>
								<td><%= view.getFieldLabel("org:opencrx:kernel:product1:AbstractProductPrice", "discount", app.getCurrentLocaleAsIndex()) %></td>
								<td class="addon"/>
							</tr>
<%
							int lastProductBasePriceIndex = -1;
							for(int i = 0; i < productBasePriceCount; i++) {
							    if(formValues.get("productBasePrice.priceLevel." + i) != null) {
							        lastProductBasePriceIndex = i;
							        java.math.BigDecimal quantityFrom = (java.math.BigDecimal)formValues.get("productBasePrice.quantityFrom." + i);
							        java.math.BigDecimal quantityTo = (java.math.BigDecimal)formValues.get("productBasePrice.quantityTo." + i);
							        java.math.BigDecimal price = (java.math.BigDecimal)formValues.get("productBasePrice.price." + i);
							        java.math.BigDecimal discount = (java.math.BigDecimal)formValues.get("productBasePrice.discount." + i);
							        org.opencrx.kernel.product1.jmi1.PriceLevel priceLevel = 
							        	(org.opencrx.kernel.product1.jmi1.PriceLevel)pm.getObjectById(
							        		formValues.get("productBasePrice.priceLevel." + i)
							        	);
%>
									<tr class="gridTableRowFull">
										<td><input class="abutton" type="submit" name="DeleteProductBasePrice.<%= i %>" value="-" onclick="javascript:$('Command').value=this.name;"/></td>
										<td><%= new ObjectReference(priceLevel, app).getTitle() %><input type="hidden" name="productBasePrice.priceLevel.<%= i %>" value="<%= priceLevel.refMofId() %>"/></td>
										<td>
<%
											for(Iterator j = ((List)formValues.get("productBasePrice.usage." + i)).iterator(); j.hasNext(); ) {
												Short usage = (Short)j.next();
%>
												<%= app.getCodes().getShortText("usageproductbaseprice", app.getCurrentLocaleAsIndex(), true, true).get(usage) %>
<%
											}
%>
											<input type="hidden" name="productBasePrice.usage.<%= i %>" value="<%= formValues.get("productBasePrice.usage." + i) %>"/>
										</td>
										<td><%= app.getCodes().getShortText("currency", app.getCurrentLocaleAsIndex(), true, true).get(formValues.get("productBasePrice.priceCurrency." + i)) %><input type="hidden" name="productBasePrice.priceCurrency.<%= i %>" value="<%= formValues.get("productBasePrice.priceCurrency." + i) %>"/></td>
										<td><input class="valueR" type="text" name="productBasePrice.quantityFrom.<%= i %>" value="<%= quantityFrom == null ? "" : quantityFrom %>"/></td>
										<td><input class="valueR" type="text" name="productBasePrice.quantityTo.<%= i %>" value="<%= quantityTo == null ? "" : quantityTo %>"/></td>
										<td><input class="valueR" type="text" name="productBasePrice.price.<%= i %>" value="<%= price == null ? "" : price %>"/></td>
										<td><input class="valueR" type="checkbox" name="productBasePrice.discountIsPercentage.<%= i %>" <%= ((Boolean)formValues.get("productBasePrice.discountIsPercentage." + i)).booleanValue() ? "checked" : "" %>"/></td>
										<td><input class="valueR" type="text" name="productBasePrice.discount.<%= i %>" value="<%= discount == null ? "" : discount %>"/></td>
										<td class="addon"/>
									</tr>
<%
							    }
							}
							productBasePriceCount = lastProductBasePriceIndex + 1;
%>
						</table>
<%
					}
					productBasePriceForm.paint(
						p,
						null, // frame
						true // forEditing
					);
					p.flush();
%>
					<input type="hidden" name="ProductBasePrice.Count" id="ProductBasePrice.Count" value="<%= productBasePriceCount %>" />
					<input type="submit" class="abutton" name="AddProductBasePrice" id="AddProductBasePrice.Button" tabindex="9000" value="+" onclick="javascript:$('Command').value=this.name;" />
					<div class="fieldGroupName">&nbsp;</div>
				</div>
				<input type="submit" class="abutton" name="OK" id="OK.Button" tabindex="9050" value="<%= app.getTexts().getSaveTitle() %>" onclick="javascript:$('Command').value=this.name;" />
				<input type="submit" class="abutton" name="Cancel" tabindex="9060" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
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
