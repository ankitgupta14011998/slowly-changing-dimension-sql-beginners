create trigger Daily_sales_analysis.FCT_Sales_after_insertion
after insert
on FCT_Sales for each row
begin 
	update dim_store_product set Stock_availability=Stock_availability-new.Sold_quantity
	where dim_store_product.Product_ID =new.product_ID_FK
	and dim_store_product.Store_Id=new.Store_ID_FK;
end



create TRIGGER Daily_sales_analysis.FCT_Sales_before_insertion BEFORE INSERT ON `fct_sales` FOR EACH ROW begin 
	DECLARE availability INT;
	declare price int;
	
	select Stock_availability into availability from dim_store_product s
	where s.Product_ID=new.Product_ID_FK and s.Store_ID=new.Store_ID_FK;
	if 
		new.Sold_quantity > availability 
	then
		signal sqlstate '45000';
	end if;

	select dp.Product_price into price from dim_product dp where dp.Product_ID_SK=new.Product_ID_FK;
		set new.Amount=new.Sold_quantity*price;
end



create trigger Daily_sales_analysis.product_historical
after update
on DIM_Product for each row 
begin 
	call history_product();
end