<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>供应商管理</title>
<link rel="stylesheet" type="text/css" href="../css/default.css"/>
<link rel="stylesheet" type="text/css" href="../js/jquery-easyui-1.3.5/themes/gray/easyui.css"/>
<link rel="stylesheet" type="text/css" href="../js/jquery-easyui-1.3.5/themes/icon.css"/>
<script type="text/javascript" src="../js/jquery-easyui-1.3.5/src/jquery.form.js"></script>
<script type="text/javascript" src="../js/jquery-easyui-1.3.5/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="../js/jquery-easyui-1.3.5/jquery.easyui.min.js"></script>
<script type="text/javascript" src="../js/jquery-easyui-1.3.5/locale/easyui-lang-zh_CN.js"></script>
<script type="text/javascript" src="../js/extends.js"></script>
<script type="text/javascript" src="../js/common.js"></script>
<script>
$(function(){
	//动态加载标题和数据
	function getData(){
		var json_data;
		$.ajax({
			async:false,
			type:"post",
			data:"",
			url:"../VendorAction!vendorList",						
			dataType:"json",
			success:function(data){
				json_data=data;
			},
			error:function(){
				json_data = "";
			}
		});	
		return json_data;	
	}
	
	$("#tt").datagrid({	
				height:$("#body").height()-$('#search_area').height()-5,
				width:$("#body").width(),
				idField:'id',
				singleSelect:false,
				selectOnCheck:true,
                checkOnSelect:true,
				nowrap:true,
				fitColumns:false,
				rownumbers:true,
				showPageList:false,
				frozenColumns: [[{field:'ck',checkbox:true}]], 
				columns:[getData().title],	//动态取标题	
				toolbar:'#tb',
				pagination:true,
				pageSize:3,
				pageList:[3,6,9],  
				onDblClickRow:function(rowIndex, rowData){
					viewDetail(rowData.id);
				},
				onLoadSuccess:function(data){}, 
                onSortColumn:function(sort,order){ datagridUtils.onSortColumn($("#tt"),sort);}					
		});	
	
 	$("#tt").datagrid({loadFilter:pagerFilter}).datagrid('loadData',getData().rows);//动态取数据
 	
        function pagerFilter(data){
        	if (typeof data.length == 'number' && typeof data.splice == 'function'){// 判断数据是否是数组
				data = {
						total: data.length,
						rows: data
						};
				}
            var dg = $(this);
            var opts = dg.datagrid('options');
            var pager = dg.datagrid('getPager');
            pager.pagination({
                onSelectPage:function(pageNum, pageSize){
                    opts.pageNumber = pageNum;
                    opts.pageSize = pageSize;
                    pager.pagination('refresh',{
                        pageNumber:pageNum,
                        pageSize:pageSize
                    });
                    dg.datagrid('loadData',data);
                }
            });
            if (!data.originalRows){
                data.originalRows = (data.rows);
            }
            var start = (opts.pageNumber-1)*parseInt(opts.pageSize);
            var end = start + parseInt(opts.pageSize);
            data.rows = (data.originalRows.slice(start, end));
            return data;
        }
        
     $("#dlg").dialog({
		collapsible:true,
		minimizable:true,
		maximizable:true,
		resizable:true,
		width:300,
		height:300,
		cache:false,
		buttons:"#dlg-buttons",
		inline:false,
		closed:true,
		shadow:false,
		model:true,
		onMinimize:function(){
			$("#dlg").dialog('move',{left:"52%",top:"90%"}).dialog('collapse').dialog('open');
		}
	});
});
//表单数据转json数据格式
	$.fn.serializeObject = function() {
			var o = {};
			var a = this.serializeArray();
			$.each(a, function() {
				if (o[this.name]) {
					if (!o[this.name].push) {
						o[this.name] = [ o[this.name] ];
					}
					o[this.name].push(this.value || '');
				} else {
					o[this.name] = this.value || '';
				}
			});
			return JSON.stringify(o);
	};
	var url;
//查询客户
	function searchCustomer() {
		$("#tt").datagrid('options').url="../VendorAction!searchVendor";
		$("#tt").datagrid('load',{
			vendorName:$("#vendorName").val(),
			address:$("#address").val(),
			vendorNo:$("#vendorNo").val()
		
		});
	}
//打开新增客户窗口
	function openCustomerAddDialog() {
		$("input[type=reset]").trigger("click");		
		$("#dlg").dialog("open").dialog("setTitle", "添加供应商信息");
		url = "../VendorAction!addVendor";
	}
//打开修改客户窗口
	function openCustomerModifyDialog() {
		$("input[type=reset]").trigger("click");
		var selectedRows = $("#tt").datagrid("getSelections");
		if (selectedRows.length != 1) {
			$.messager.alert("系统提示", "请选择一条要编辑的数据！");
			return;
		}
		var row = selectedRows[0];
		$("#dlg").dialog("open").dialog("setTitle", "编辑供应商信息");
		$("#fm").form("load", row);
		url = "../VendorAction!updateVendor";
	}
	
//ajax方式提交form表单	
	function saveCustomer() {
		$.ajax({
			type : "POST",
			dataType : "json",
			url : url,
			data : "str="+$("#fm").serializeObject(),
			success : function(data) {
				$.messager.alert("系统提示", "保存成功！");							
				$("#dlg").dialog("close");
				$("#tt").datagrid({url:"../VendorAction!vendorList"});							
				$("input[type=reset]").trigger("click");
			},
			error : function(data) {
				$.messager.alert("系统提示", "保存失败！");
			}
	});
	
	}
//关闭窗口
	function closeCustomerDialog() {		
		$("#dlg").dialog("close");	
		$("input[type=reset]").trigger("click");	
	}
//删除用户
	function deleteCustomer() {
		var selectedRows = $("#tt").datagrid("getSelections");
		if (selectedRows.length == 0) {
			$.messager.alert("系统提示", "请选择要删除的数据！");
			return;
		}
		var customerIds = [];
		for ( var i = 0; i < selectedRows.length; i++) {
			customerIds.push(selectedRows[i].id);
		}
		var ids = customerIds.join(",");
		$.messager.confirm("系统提示", "您确定要删除这 <font color=red>"
				+ selectedRows.length + "</font> 条数据吗？", function(r) {
			if (r) {
		$.ajax({
			type : "POST",
			dataType : "json",
			url : "../VendorAction!deleteVendor",
			data : "ids="+ids,
			success : function(data) {
				$.messager.alert("系统提示", "数据已成功删除！");				
				$("#tt").datagrid({url:"../VendorAction!vendorList"});
				selectedRows.length=0;
			},
			error:function(data) {
				$.messager.alert("系统提示", "数据删除失败，请联系系统管理员！");
				selectedRows.length=0;
			}
			
	});
			}
		});
	}
	function viewDetail(date, id) {
		$parent.messager.alert("提示", "查询详细", "info");
	}
//查询条件清空
 function resetValue(){
 	$("#bb input").val("");
 }
	//监听窗口大小变化
	window.onresize = function() {
		setTimeout(domresize, 300);
	};
	//改变表格宽高
	function domresize() {
		$('#tt').datagrid('resize', {
			height : $("#body").height() - $('#search_area').height() - 5,
			width : $("#body").width()
		});
	};
</script>
</head>
<body class="easyui-layout" >
<div id="body" region="center" > 
  <!-- 查询条件区域 -->
  <div id="search_area" >
    <div id="conditon">
      <table id="bb" border="0">
        <tr>
          <td>供应商姓名：</td>
          <td ><input  name="vendorName" id="vendorName"/></td>
          <td>&nbsp;地址：</td>
          <td><input  name="address" id="address"/></td>
          <td>&nbsp;编号：</td>
          <td><input  name="vendorNo" id="vendorNo"/></td>
          <td>
              <a href="javascript:searchCustomer()" class="easyui-linkbutton" iconCls="icon-search" plain="true">查询</a> 
              <a href="javascript:resetValue()" class="easyui-linkbutton" iconCls="icon-reset" plain="true" >重置</a>
          </td>
        </tr>
      </table>
    </div>
    <span id="openOrClose">111</span> 
  </div>
  <!-- 数据表格区域 -->
  <table id="tt" style="table-layout:fixed;" ></table>
  <!-- 表格顶部工具按钮 -->
    <div id="tb">
        <a href="javascript:openCustomerAddDialog()" id="ddd" class="easyui-linkbutton" iconCls="icon-add" plain="true">新增</a> 
        <a href="javascript:openCustomerModifyDialog()" class="easyui-linkbutton" iconCls="icon-edit" plain="true">修改</a> 
        <a href="javascript:deleteCustomer()" class="easyui-linkbutton" iconCls="icon-remove" plain="true">删除</a>
    </div>
   <!-- 添加客户信息及修改客户信息 弹出框 -->
       <div id="dlg" class="easyui-dialog" closed="true">
            <form id="fm">
                <table cellspacing="8px;">
                 <tr>
      <td>ID：</td>
      <td><input type="text" name="id" id="id" class="easyui-validatebox" required="true" />
      &nbsp;<span style="color: red">*</span></td></tr>
                      <tr>
      <td>供应商编号：</td>
      <td><input type="text" name="vendorNo" id="vendorNo" class="easyui-validatebox" required="true" />
      &nbsp;<span style="color: red">*</span></td>
      </tr>
      <tr>
      <td>姓名：</td>
      <td><input type="text" name="vendorName" id="vendorName" class="easyui-validatebox" required="true" />
      &nbsp;<span style="color: red">*</span></td>
      </tr>
      <tr>
        <td>地址：</td>
        <td><input type="text" name="address" id="address" class="easyui-validatebox" required="true" />
      &nbsp;<span style="color: red">*</span></td>
     </tr>
     <tr>
        <td>电话：</td>
        <td><input type="text" name="telephone" id="telephone" class="easyui-validatebox" required="true" />
      &nbsp;<span style="color: red">*</span></td>
      </tr>
      <tr>
        <td>信誉：</td>
        <td><input type="text" name="reputation" id="reputation" panelHeight="50" class="easyui-combobox" data-options="valueField:'value',textField:'text',data:[{'value':'优秀','text':'优秀'},{'value':'良好','text':'良好'},{'value':'差','text':'差'}]" required="true" />
      &nbsp;<span style="color: red">*</span></td>
      </tr>
      <tr>
        <td>网址：</td>
        <td><input type="text" name="websites" id="websites" class="easyui-validatebox" required="true" />
      &nbsp;<span style="color: red">*</span></td>
      </tr>
      <tr>
        <td>领导人名称：</td>
        <td><input type="text" name="headerName" id="headerName" class="easyui-validatebox" required="true" />
      &nbsp;<span style="color: red">*</span></td>
    </tr>
    <tr>
        <td>领导人性别：</td>
        <td><input type="text" name="headerSex" id="headerSex" panelHeight="50" class="easyui-combobox" data-options="valueField:'value',textField:'text',data:[{'value':'男','text':'男'},{'value':'女','text':'女'}]" required="true" />
      &nbsp;<span style="color: red">*</span></td>
      </tr>
                </table>
                 <!--隐藏按钮,用于清空表单-->
                <input type="reset" style="display:none;" />
            </form>
        </div>
        
		<div id="dlg-buttons">
            <a href="javascript:saveCustomer()" class="easyui-linkbutton" iconCls="icon-ok">保存</a> 
            <a href="javascript:closeCustomerDialog()" class="easyui-linkbutton" iconCls="icon-cancel">关闭</a>
        </div>
</div>
</body>
</html>