
module IntDK
  class ProjectModel
    attr_reader :project_id, :client_id, :floor_gp
    attr_accessor :project_type 
  end   

  class FloorModel
    attr_reader :room_name
    attr_accessor :wall_depth, :tile_material 

    def initialize(params = {})
      @floor_face = params[:floor_face]
      @wall_depth = params[:wall_depth]
      @tile_material = params[:tile_material]
      @floor_gp = create_floor
      @floor_gp
    end

    def create_floor 
      model = Sketchup.active_model 
      ents = model.entities 
      floor_entities = [@floor_face]
      floor_group = ents.add_group floor_entities
      floor_group
    end    
  end

  class WallModel
    attr_reader :start_pt, :end_pt, :width
    attr_accessor :front_material, :room_name 

    def initialize(params={})
      puts "Params : #{params}"
    end
  end

  class ComponentModel
    attr_accessor :width, :height, :depth 
  end
end

module CivilHelper
  extend self
  def get_cw_edge_vector edge, face
    edge_vector = edge.line[1]
    perp_vector = Geom::Vector3d.new(edge_vector.y, -edge_vector.x, edge_vector.z)
    offset_pt 	= edge.bounds.center.offset(perp_vector, 2.mm)
    res = face.classify_point(offset_pt)

    if (res == Sketchup::Face::PointInside || res == Sketchup::Face::PointOnFace)
      conn_vector = perp_vector 
    else
      conn_vector =  perp_vector.reverse
    end 

    dot_vector	= conn_vector * edge.line[1] 
    cw_vector = (dot_vector.z > 0 ? edge_vector : edge_vector.reverse) 
    return [cw_vector, conn_vector]
  end

  def find_views input_face
    return {} if input_face.nil? || !input_face.is_a?(Sketchup::Face) 
    
    views_h = {}
    curr_vector = ""
    vcounter = 1
    
    input_face.outer_loop.edges.each {|edge|
      edge_vector, conn_vector = get_cw_edge_vector edge, input_face
      edge_vector.z = 0
      puts "Edge VT : #{edge_vector}"
      
      
      view_key = "view_#{vcounter}@#{edge_vector.to_s}"
      if view_key != curr_vector 
        curr_vector = view_key 
        vcounter += 1
      end
      views_h[view_key] = { :edges => [], :wall_to_floor_vector => conn_vector} if views_h[edge_vector.to_s].nil?
      views_h[view_key][:edges] << edge
    }
    return views_h
  end

  def str_to_vec(input_str)
    vec_values = input_str[1..-2].split(", ").map(&:to_f)
    Geom::Vector3d.new(vec_values[0], vec_values[1], vec_values[2])
  end

  def create_block start_pt, end_pt, wall_vector, distance = 100.mm, height = 2000.mm

    defn_name = 'temp_defn' + Time.now.strftime("%T%m")
    model		  = Sketchup.active_model
    entities 	= model.entities
    defns		  = model.definitions
    comp_defn	= defns.add defn_name

    length  = start_pt.distance end_pt
    width   = distance 
    
    pt1 		= ORIGIN
    pt2			= ORIGIN.offset(Y_AXIS, width)
    pt3 		= pt2.offset(X_AXIS, length)
    pt4 		= pt1.offset(X_AXIS, length)

    wall_temp_group 	= comp_defn.entities.add_group
    wall_temp_face 		= wall_temp_group.entities.add_face(pt1, pt2, pt3, pt4)
    wall_temp_face.material = 'orange'
    wall_temp_face.back_material = 'orange'

    # ent_list1 	= Sketchup.active_model.entities.to_a
    # puts "Ent_list1 : #{} #{ent_list1.length}"
    wall_temp_face.pushpull -height
    # ent_list2 	= Sketchup.active_model.entities.to_a
    # puts "Ent_list2 : #{} #{ent_list2.length}"

    # new_entities 	= ent_list2 - ent_list1

    wall_temp_group.entities.grep(Sketchup::Face).each { |tface|
      front_face = true
      (0..7).each {|i| 
        puts tface.bounds.corner(i)
        front_face = false if tface.bounds.corner(i).y > 0
      }
      if front_face 
        tface.material = 'orange'
        tface.back_material = 'orange'
      else
        tface.edges.each{|edge| 
          if edge.vertices[0].position.z == 0 && edge.vertices[1].position.z ==0
          else
            edge.hidden = true
          end
        }
      end
      #wall_temp_group.entities.add_face tface
    }

    block_inst = Sketchup.active_model.entities.add_instance comp_defn, start_pt

    wall_vector = start_pt.vector_to(end_pt)
    extra = 0
    if wall_vector.y < 0
        wall_vector.reverse!
        extra = Math::PI
    end
    
    angle 	= extra + X_AXIS.angle_between(wall_vector)
    block_inst.transform!(Geom::Transformation.rotation(start_pt, Z_AXIS, angle))
    block_inst.explode
    
    
    block_inst
  end

  def create_outer_closures input_face
    model = Sketchup.active_model
    active_ents = model.entities

    views_h = find_views(input_face)
    
    count = 1
    wall_views = {}
    
    views_h.each_pair { |vector_str, details|
      edges_array = details[:edges]
      edge_vector = str_to_vec(vector_str)
      
      start_edge = edges_array[0]
      end_edge = edges_array[-1]
      
      sp_verts = start_edge.vertices
      ep_verts = end_edge.vertices
      
      start_pt  = start_edge.line[1] == edge_vector ? sp_verts[0] : sp_verts[1]
      end_pt    = end_edge.line[1] == edge_vector ? ep_verts[1] : ep_verts[0]
      
      wall_views["view_#{count}"] = {:start_pt => start_pt.position, :end_pt => end_pt.position, :wall_to_floor_vector => details[:wall_to_floor_vector]}
      create_block start_pt.position, end_pt.position, details[:wall_to_floor_vector]
      
      count += 1
    }
    wall_views
  end
end 

input_face  = Sketchup.active_model.selection[0]
resp        = CivilHelper::create_outer_closures input_face
puts "Resp : #{resp}"