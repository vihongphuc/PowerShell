-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE or alter PROCEDURE CRUD_Country 
	@id int,
	@name	nvarchar(max),
	@description nvarchar(max),
	@version  nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    if not exists (select top 1 1 from Country where Id = @id)
	begin
		insert into Country (Id, [Name], [Description], [Version])
		values (@id, @name, @description, @version)
	end
	else if exists (select top 1 1 from Country where Id = @id and [Version] != @version)
	begin
		update Country 
		set [Description] =@description
		, [Version] =@version
		where Id=@id
	end
END
GO
