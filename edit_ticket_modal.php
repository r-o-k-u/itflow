<div class="modal" id="editTicketModal<?php echo $ticket_id; ?>" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content bg-dark">
      <div class="modal-header">
        <h5 class="modal-title"><i class="fa fa-fw fa-tag"></i> Ticket <?php echo "$ticket_prefix$ticket_number"; ?> for <?php echo $client_name; ?></h5>
        <button type="button" class="close text-white" data-dismiss="modal">
          <span>&times;</span>
        </button>
      </div>
      <form action="post.php" method="post" autocomplete="off">
        <input type="hidden" name="ticket_id" value="<?php echo $ticket_id; ?>">
        <div class="modal-body bg-white">
        
          <div class="form-group">
            <label>Assigned to</label>
            <div class="input-group">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="fa fa-fw fa-user"></i></span>
              </div>
              <select class="form-control select2" name="assigned_to">
                <option value="">Not Assigned</option>
                <?php 
                
                $sql_assign_to_select = mysqli_query($mysqli,"SELECT * FROM users, permissions WHERE users.user_id = permissions.user_id AND $session_company_id IN($session_permission_companies) ORDER BY name ASC");
                while($row = mysqli_fetch_array($sql_assign_to_select)){
                  $user_id = $row['user_id'];
                  $name = $row['name'];
                ?>
                <option <?php if($ticket_assigned_to == $user_id){ echo "selected"; } ?> value="<?php echo $user_id; ?>"><?php echo $name; ?></option>
                
                <?php
                }
                ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>Priority <strong class="text-danger">*</strong></label>
            <div class="input-group">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="fa fa-fw fa-thermometer-half"></i></span>
              </div>
              <select class="form-control select2" name="priority" required>
                <option <?php if($ticket_priority == 'Low'){ echo "selected"; } ?> >Low</option>
                <option <?php if($ticket_priority == 'Medium'){ echo "selected"; } ?> >Medium</option>
                <option <?php if($ticket_priority == 'High'){ echo "selected"; } ?> >High</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>Subject <strong class="text-danger">*</strong></label>
            <div class="input-group">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="fa fa-fw fa-tag"></i></span>
              </div>
              <input type="text" class="form-control" name="subject" value="<?php echo $ticket_subject; ?>" placeholder="Subject" required>
            </div>
          </div>
          
          <div class="form-group">
            <label>Details <strong class="text-danger">*</strong></label>
            <textarea class="form-control summernote" rows="8" name="details" required><?php echo $ticket_details; ?></textarea>
          </div>

        </div>
        <div class="modal-footer bg-white">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
          <button type="submit" name="edit_ticket" class="btn btn-primary">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>