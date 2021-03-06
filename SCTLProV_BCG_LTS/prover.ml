open Printf
open Formula
open Bcg_interface
open Lts

exception Deadlock of Bcg_interface.state

let deadlock = ref false

type continuation = 
      Basic of bool
    | Cont of State_set.t * string * formula * continuation * continuation * ((string * (state)) list) * ((string * (state)) list)

exception Error_proving_atomic
exception Unable_to_prove

let rec list_conditional lst c f = 
	match lst with
	| [] -> c
	| elem :: lst' -> if f elem = c then list_conditional lst' c f else not c

let true_merge = Hashtbl.create 10
let false_merge = Hashtbl.create 10

let is_in_true_merge s levl modl = 
	try
		State_set.mem s (Hashtbl.find true_merge levl)
	with Not_found -> print_endline ("level not found in finding true merge: "^levl); exit 1

let is_in_false_merge s levl modl = 
	State_set.mem s (Hashtbl.find false_merge levl)

let add_to_true_merge s levl modl = 
	try
		let bss = Hashtbl.find true_merge levl in
		Hashtbl.replace true_merge levl (State_set.add s bss)
	with Not_found -> print_endline ("level not found in finding true merge: "^levl); exit 1
let add_to_false_merge s levl modl = 
	try
		let bss = Hashtbl.find false_merge levl in
		Hashtbl.replace false_merge levl (State_set.add s bss)
	with Not_found -> print_endline ("level not found in finding false merge: "^levl); exit 1

let add_true_to_cont levl s cont = 
	match cont with
	| Cont (gamma, cont_levl, fml, contl, contr, ts, fs) -> Cont (gamma, cont_levl, fml, contl, contr, (levl, s)::ts, fs)
	| _ -> cont

let add_false_to_cont levl s cont = 
	match cont with
	| Cont (gamma, cont_levl, fml, contl, contr, ts, fs) -> Cont (gamma, cont_levl, fml, contl, contr, ts, (levl, s)::fs)
	| _ -> cont

(****************************)

	(*whether state s is already in an existing merge*)
let merges = Hashtbl.create 10
let pre_process_merges sub_fml_tbl = 
	Hashtbl.iter (fun a b -> Hashtbl.add merges a (State_set.empty)) sub_fml_tbl;
	Hashtbl.iter (fun a b -> Hashtbl.add true_merge a (State_set.empty)) sub_fml_tbl;
	Hashtbl.iter (fun a b -> Hashtbl.add false_merge a (State_set.empty)) sub_fml_tbl

let get_merge levl = 
	Hashtbl.find merges levl

let in_global_merge s level modl = 
	State_set.mem s (Hashtbl.find merges level)

let add_to_global_merge ss level modl = 
	let sts = Hashtbl.find merges level in
	Hashtbl.replace merges level (State_set.fold (fun elem b -> State_set.add elem b) ss sts)
    
let clear_global_merge level = 
	Hashtbl.replace merges level (State_set.empty)
let get_global_merge level = 
	Hashtbl.find merges level


let generate_EX_cont gamma levl x fml next contl contr = 
    State_set.fold (fun elem b ->
        Cont (State_set.empty, levl^"1", (subst_s fml (SVar x) (State elem)), contl, b, [], [])) next contr

let generate_AX_cont gamma levl x fml next contl contr = 
    State_set.fold (fun elem b ->
        Cont (State_set.empty, levl^"1", (subst_s fml (SVar x) (State elem)), b, contr, [], [])) next contl 

let generate_EG_cont gamma level act x fml s next contl contr =
	let level1 = level^"1" in
    let nested = State_set.fold
        (fun elem b -> 
            Cont (State_set.add s gamma, level, EG(act, x, fml, State elem), contl, add_false_to_cont level elem b, [], [])) next contr in
	Cont (State_set.empty, level1, subst_s fml (SVar x) (State s), nested, contr, [], [])

let generate_AF_cont gamma levl act x fml s next contl contr =
	let level1 = levl^"1" in 
    let nested = State_set.fold
        (fun elem b ->
            Cont (State_set.add s gamma, levl, AF(act, x, fml, State elem), add_true_to_cont levl elem b, contr, [], [])) next contl in
	Cont (State_set.empty, level1, subst_s fml (SVar x) (State s), contl, nested, [], [])

let generate_EU_cont gamma levl act x y fml1 fml2 s next contl contr = 
	let levl1 = levl^"1"
	and levl2 = levl^"2" in
	let nested = State_set.fold
			(fun elem b -> 
					Cont (State_set.singleton s, levl, EU(act, x, y, fml1, fml2, State elem), contl, b, [], [])) next contr in
		Cont (State_set.empty, levl2, subst_s fml2 (SVar y) (State s), 
		contl,
		Cont (State_set.empty, levl1, subst_s fml1 (SVar x) (State s),
			nested,
			contr, 
			[], []),
		[], [])

let generate_AR_cont gamma levl act x y fml1 fml2 s next contl contr = 
	let levl1 = levl^"1"
	and levl2 = levl^"2" in
	let nested = State_set.fold
		(fun elem b ->
	Cont (State_set.singleton s, levl, AR (act, x, y, fml1, fml2, State elem), b, contr, [], [])) next contl in
	Cont (State_set.empty, levl2, subst_s fml2 (SVar y) (State s),
	Cont (State_set.empty, levl1, subst_s fml1 (SVar x) (State s), 
		contl,
		nested,
		[], []),
	contr,
	[], [])

and prove_atomic s sl modl = 
	match s with
	(* | "is_state" -> begin
			match (List.hd sl) with
			| State ss -> is_state ss
			| _ -> false
		end
	| "is_label" -> begin
		match (List.hd sl) with
		| State ss -> is_label ss
		| _ -> false
	end *)
	| _ -> printf "Unknown atomic predicate: %s\n" s; exit 1

let rec prove cont modl = 
    match cont with 
    | Basic b -> b
    | Cont (gamma, levl, fml, contl, contr, ts, fs) ->
		(
			List.iter (fun (a, b) -> if a<>"-1" then add_to_true_merge b a modl) ts;
			List.iter (fun (a, b) -> if a<>"-1" then add_to_false_merge b a modl) fs
		);
		begin
				match fml with
				| Top -> prove contl modl
				| Bottom -> prove contr modl
				| Atomic (s, sl) -> if prove_atomic s sl modl then prove contl modl else prove contr modl
				| Neg (Atomic (s, sl)) -> if prove_atomic s sl modl then prove contr modl else prove contl modl
				| Neg fml1 -> prove (Cont (gamma, levl^"1", fml1, contr, contl, [], [])) modl
				| And (fml1, fml2) -> 
						prove (Cont (State_set.empty, levl^"1", fml1, 
														Cont (State_set.empty, levl^"2", fml2,
																contl, 
																contr, 
							[],[]), 
														contr,
						[],[])) modl
				| Or (fml1, fml2) -> 
						prove (Cont (State_set.empty, levl^"1", fml1,
														contl,
														Cont (State_set.empty, levl^"2", fml2,
																contl,
																contr, [],[]),[],[])) modl
				| AX (act, x, fml1, State s) -> 
						let next = next s act in
						if State_set.is_empty next && !deadlock then
							raise (Deadlock s)
						else
							prove (generate_AX_cont gamma levl x fml1 next contl contr) modl
				| EX (act, x, fml1, State s) -> 
						let next = next s act in
						if State_set.is_empty next && !deadlock then
							raise (Deadlock s)
						else
							prove (generate_EX_cont gamma levl x fml1 next contl contr) modl
				| EG (act, x, fml1, State s) -> 
						if (is_in_true_merge s levl modl) then prove contl modl else
						if (is_in_false_merge s levl modl) then prove contr modl else 
							if State_set.mem s gamma 
							then  
									prove contl modl
							else
									let next = next s act in
									if State_set.is_empty next && !deadlock then
										raise (Deadlock s)
									else 
										prove (generate_EG_cont gamma levl act x fml1 s next contl contr) modl
				| AF (act, x, fml1, State s) -> 
						if is_in_true_merge s levl modl then prove contl modl else
						if is_in_false_merge s levl modl then prove contr modl else
						begin
							if State_set.mem s gamma
							then 
								prove contr modl
							else 
								begin
									let next = next s act in
									if State_set.is_empty next && !deadlock then
										raise (Deadlock s)
									else
										prove (generate_AF_cont gamma levl act x fml1 s next contl contr) modl
								end
						end
				| EU (act, x, y, fml1, fml2, State s) -> 
					(
						if State_set.is_empty gamma 
						then clear_global_merge levl 
						else add_to_global_merge gamma levl modl;
						if in_global_merge s levl modl
						then
							prove contr modl
						else
							let next = next s act in
							if State_set.is_empty next && !deadlock then
								raise (Deadlock s)
							else
								let new_next = State_set.diff next (get_merge levl) in
								prove (generate_EU_cont gamma levl act x y fml1 fml2 s new_next contl contr) modl
					) 
				| AR (act, x, y, fml1, fml2, State s) ->
					(
						(if State_set.is_empty gamma
						then clear_global_merge levl
						else add_to_global_merge gamma levl modl;
						(*print_endline ("AR merge size: "^(string_of_int (State_set.cardinal (Hashtbl.find merges levl))))*)
						);		
						if in_global_merge s levl modl
						then 
							prove contl modl
						else
							let next = next s act in
							if State_set.is_empty next && !deadlock then
								raise (Deadlock s)
							else
								let new_next = State_set.diff next (get_merge levl) in
								prove (generate_AR_cont gamma levl act x y fml1 fml2 s new_next contl contr) modl
					) 
				| _ -> (print_endline ("Unable to prove: "^(fml_to_string fml)); raise Unable_to_prove)
		end

	let rec prove_model modl spec_lst = 
		let rec prove_lst lst = 
		match lst with
		| [] -> ()
		| (s, fml) :: lst' -> 
			((let nnf_fml = nnf fml in 
			print_endline (s^" = "^fml_to_string (nnf_fml));
			pre_process_merges (select_sub_fmls (sub_fmls nnf_fml "1"));
			begin
				let b = (prove (Cont (State_set.empty, "1", Formula.subst_s (nnf_fml) (SVar "s") (State modl.init), Basic true, Basic false, [], [])) modl) in
				print_endline (s ^ " : " ^ (string_of_bool b))
			(* with Deadlock s ->
				print_endline "deadlock detected!!!"	 *)
			end);
			 prove_lst lst') 
		in prove_lst spec_lst
			 






