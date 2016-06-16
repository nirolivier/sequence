/*
* Generate a new custom sequence of character.
* @Author: n.razafindrabekoto
* @since: R21
*/
CREATE OR REPLACE FUNCTION SEQ_CUSTOM_NUMBER RETURN SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE
IS
	TYPE t_array IS TABLE OF SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE INDEX BY BINARY_INTEGER;

	/*=======================================================
	 	Functions declaration
	 =======================================================*/
	/*
	* Convert the string to array.
	*/
   	FUNCTION string2Array(in_strings SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE) RETURN t_array
   	IS
		
		out_array t_array;		
		l_str 	  INTEGER 	:= 0;
		pos 	  INTEGER 	:= 0;
		
   	BEGIN
		IF in_strings IS NOT NULL AND in_strings <> '' THEN
			l_str := LENGTH(in_strings);
			
			-- Check if string length is greater than the t_array length.
			IF l_str <= t_array.count THEN
				FOR pos IN 1..(l_str-1)
				LOOP
					-- put into the array
					out_array(pos) := SUBSTR(in_strings,pos,1);
				END LOOP;
			END IF;
			
		END IF;
		
		RETURN out_array;
   	END string2Array;
	
	/*
	* Generate alpha sequence
	*/
   	FUNCTION nextAlphaSequence(in_strings SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE) RETURN SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE
   	IS
		CHAR A = 0x41;
		CHAR Z = 0x5A;
		CHAR a = 0x61;
		CHAR z = 0x7A;
		
		new_seq 	SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE;
		out_array 	t_array;
		ch			CHAR(1);
		
   	BEGIN
		-- Convert the string to array
		out_array := string2Array(in_strings);
		
		FOR l_pos IN REVERSE 1..out_array.count
		LOOP
			ch := TO_CHAR(out_array(l_pos));
			IF  (a <= ch AND ch < z) OR
				(A <= ch AND ch < Z)
			THEN
				out_array(l_pos) := CAST((out_array(l_pos) + 0x01) AS CHAR)
				EXIT;
			ELSE IF ch = Z THEN
				out_array(l_pos) := A;
			ELSE IF ch = z THEN
				out_array(l_pos) := a;
			END IF;
		END LOOP;
		
		FOR f_pos IN 1..out_array.count
		LOOP
			new_seq := CONCAT(new_seq, out_array(f_pos));
		END LOOP;
		
		RETURN new_seq;
   	END nextAlphaSequence;
	
	
	/*=======================================================
	 	Variable declaration
	 =======================================================*/
	def_sqcn_type 	CONSTANT VARCHAR2(255) := 'CustomerNumber';
	def_sqcn_var 	CONSTANT VARCHAR2(255) := 'Prefix';
	def_sqcn_upfx 	CONSTANT VARCHAR2(255) := 'PrefixNotToBeUsed';
	def_sqcn_val 	CONSTANT VARCHAR2(255) := 'AAA';
	
	rec_count 		INTEGER := 0;
	nx_ora_seq		INTEGER := 0;
	new_seq 		SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE;	
	alpha_seq		SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE;
	
	v_sqcn_max_id 	SEQ_CUSTOMER_NUM.SQCN_IDENT%TYPE;
	v_sqcn_ident 	SEQ_CUSTOMER_NUM.SQCN_IDENT%TYPE;
	v_sqcn_type 	SEQ_CUSTOMER_NUM.SQCN_TYPE%TYPE;
	v_sqcn_var 		SEQ_CUSTOMER_NUM.SQCN_VARIABLE%TYPE;
	v_sqcn_value 	SEQ_CUSTOMER_NUM.SQCN_VALUE%TYPE;
	
	seq_found BOOLEAN := FALSE;
	
BEGIN
	
	/*=======================================================
	 	Entry point of the program.
	 =======================================================*/
	
	/* count the existing record*/
	SELECT COUNT(seq.SQCN_IDENT)
	INTO rec_count
	FROM SEQ_CUSTOMER_NUM seq 
	WHERE seq.SQCN_TYPE 	= def_cn_type 
	AND seq.SQCN_VARIABLE 	= def_sqcn_var;
	
	/* Return whenever possible*/
	IF 	rec_count = 0 THEN
		-- Select max of ident
		SELECT MAX(seq.SQCN_IDENT) INTO v_sqcn_max_id FROM SEQ_CUSTOMER_NUM seq;
		
		-- Create new entry of sequence begining with character sequence 'A'.		
		INSERT INTO SEQ_CUSTOMER_NUM(SQCN_IDENT, SQCN_TYPE,SQCN_VARIABLE,SQCN_VALUE) 
		VALUES ((v_sqcn_max_id + 1), def_sqcn_type, def_sqcn_var, def_sqcn_val);

		-- call oracle sequence
		SELECT SEQ_ORA_CUSTOMER_NUM.NEXTVAL INTO nx_ora_seq FROM DUAL;	
		new_seq := def_sqcn_val || LPAD(TO_CHAR(nx_ora_seq),3,'0');
		RETURN new_seq;
	END IF;
	
	IF v_sqcn_value IS NULL THEN
		-- update record with initial value			
		UPDATE SEQ_CUSTOMER_NUM seq SET  seq.SQCN_VALUE = def_sqcn_val WHERE seq.SQCN_IDENT = v_sqcn_ident;			

		-- call oracle sequence
		SELECT SEQ_ORA_CUSTOMER_NUM.NEXTVAL INTO nx_ora_seq FROM DUAL;	
		new_seq := def_sqcn_val || LPAD(TO_CHAR(nx_ora_seq),3,'0');
		RETURN new_seq;
	END IF;
	
	
	IF 	v_sqcn_type  IS NULL THEN
		-- update record with initial value
		UPDATE SEQ_CUSTOMER_NUM seq SET  seq.SQCN_TYPE = def_sqcn_type WHERE seq.SQCN_IDENT = v_sqcn_ident;
	END IF;

	IF 	v_sqcn_var   IS NULL THEN
		-- update record with initial value
		UPDATE SEQ_CUSTOMER_NUM seq SET  seq.SQCN_VARIABLE = def_sqcn_var WHERE seq.SQCN_IDENT = v_sqcn_ident;
	END IF;
	
	-- select all prefixs not to be used
	SELECT notPrefix.SQCN_VALUE INTO  FROM SEQ_CUSTOMER_NUM notPrefix 
	WHERE notPrefix.SQCN_TYPE 	 = def_sqcn_type 
	AND notPrefix.SQCN_VARIABLE  = def_sqcn_upfx;
	
	-- Process the generation of sequence Lock the row for update
	SELECT seq.SQCN_IDENT, seq.SQCN_TYPE,seq.SQCN_VARIABLE,seq.SQCN_VALUE 
	INTO v_sqcn_ident, v_sqcn_type, v_sqcn_var, v_sqcn_value
	FROM SEQ_CUSTOMER_NUM seq 
	WHERE seq.SQCN_TYPE 	= def_cn_type 
	AND seq.SQCN_VARIABLE 	= def_sqcn_var
	AND ROWNUM = 1
	FOR UPDATE;
	
	WHILE NOT seq_found
	LOOP
		alpha_seq := nextAlphaSequence(v_sqcn_value);
		
		IF THEN
			
		END IF;
		seq_found := TRUE;
	END LOOP;
	
	
	UPDATE SEQ_CUSTOMER_NUM seq SET  seq.SQCN_VALUE = alpha_seq WHERE seq.SQCN_IDENT = v_sqcn_ident;
	SELECT SEQ_ORA_CUSTOMER_NUM.NEXTVAL INTO nx_ora_seq FROM DUAL;		
	new_seq := alpha_seq || LPAD(TO_CHAR(nx_ora_seq),3,'0');
	
	RETURN new_seq;
	
END SEQ_CUSTOM_NUMBER;