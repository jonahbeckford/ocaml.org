type metadata = {
  id : string;
  title : string;
  description : string;
  date : string;
  category : string;
}
[@@deriving yaml]

let path = Fpath.v "data/tutorials/"

type t = {
  title : string;
  slug : string;
  fpath : string;
  description : string;
  date : string;
  category : string;
  toc_html : string;
  body_md : string;
  body_html : string;
}

let proficiency_list_of_string_list =
  List.map (fun x ->
      match Meta.Proficiency.of_string x with
      | Ok x -> x
      | Error (`Msg err) -> raise (Exn.Decode_error err))

let to_plain_text t =
  let buf = Buffer.create 1024 in
  let rec go : _ Omd.inline -> unit = function
    | Concat (_, l) -> List.iter go l
    | Text (_, t) | Code (_, t) -> Buffer.add_string buf t
    | Emph (_, i)
    | Strong (_, i)
    | Link (_, { label = i; _ })
    | Image (_, { label = i; _ }) ->
        go i
    | Hard_break _ | Soft_break _ -> Buffer.add_char buf ' '
    | Html _ -> ()
  in
  go t;
  Buffer.contents buf

let doc_with_ids doc =
  let open Omd in
  List.map
    (function
      | Heading (attr, level, inline) ->
          let attr =
            match List.assoc_opt "id" attr with
            | Some _ -> attr
            | None -> ("id", Utils.slugify (to_plain_text inline)) :: attr
          in
          Heading (attr, level, inline)
      | el -> el)
    doc

let filter_heading_1 doc =
  let open Omd in
  List.filter (function Heading (_attr, 1, _inline) -> false | _ -> true) doc

let all () =
  Utils.map_files_with_names
    (fun (file, content) ->
      let metadata, body = Utils.extract_metadata_body content in
      let metadata = Utils.decode_or_raise metadata_of_yaml metadata in
      let omd = doc_with_ids (Omd.of_string body) in
      let toc_doc = filter_heading_1 omd in
      {
        title = metadata.title;
        fpath = file;
        slug = metadata.id;
        description = metadata.description;
        date = metadata.date;
        category = metadata.category;
        toc_html = Omd.to_html (Omd.toc ~depth:4 toc_doc);
        body_md = body;
        body_html = Omd.to_html (Hilite.Md.transform omd);
      })
    "tutorials/*.md"

let pp ppf v =
  Fmt.pf ppf
    {|
  { title = %a
  ; fpath = %a
  ; slug = %a
  ; description = %a
  ; date = %a
  ; category = %a
  ; body_md = %a
  ; toc_html = %a
  ; body_html = %a
  }|}
    Pp.string v.title Pp.string v.fpath Pp.string v.slug Pp.string v.description
    Pp.string v.date Pp.string v.category Pp.string v.body_md Pp.string
    v.toc_html Pp.string v.body_html

let pp_list = Pp.list pp

let template () =
  Format.asprintf
    {|
type t =
  { title : string
  ; fpath : string
  ; slug : string
  ; description : string
  ; date : string
  ; category : string
  ; body_md : string
  ; toc_html : string
  ; body_html : string
  }
  
let all = %a
|}
    pp_list (all ())
